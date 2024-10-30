package main

import (
  "context"
  "os"
  "time"
  "fmt"
  "net/http"
  "encoding/json"

  "database/sql"
  _ "github.com/lib/pq"

	"github.com/redis/go-redis/v9"
)

// Postgres connection variables
var (
  host     = os.Getenv("DATABASE_HOST")
  port     = os.Getenv("DATABASE_PORT")
  user     = os.Getenv("DATABASE_USER")
  password = os.Getenv("DATABASE_PASSWORD")
  dbname   = os.Getenv("DATABASE_NAME")
)

// Redis connection variables
var (
  rhost = os.Getenv("REDIS_HOST")
  rpassword = os.Getenv("REDIS_PASSWORD")
  rport = os.Getenv("REDIS_PORT")
	ctx = context.Background()
)

// Types
type RequestLogger struct {
  Time time.Time
  RemoteAddr string
  StatusCode uint
  Path string
}

type Health struct {
  Status string
  Database string
  Cache string
}

type PageVisits struct {
	Key   string `json:"key"`
	Value string `json:"value"`
}

type PgStats struct {
  Username string
  Database string
  ClientAddr string
  State string
}

// Helper functions
func logger(r *http.Request) {
  u, err := json.Marshal(
    RequestLogger{
      Time: time.Now().UTC(), 
      RemoteAddr: r.RemoteAddr, 
      StatusCode: http.StatusOK, 
      Path: r.URL.Path,
    })

  if err != nil {
      panic(err)
  }

  fmt.Printf("%v\n", string(u))
}

func errlogger(r *http.Request) {
  u, err := json.Marshal(
    RequestLogger{
      Time: time.Now().UTC(), 
      RemoteAddr: r.RemoteAddr, 
      StatusCode: http.StatusNotFound, 
      Path: r.URL.Path,
    })

  if err != nil {
      panic(err)
  }

  fmt.Printf("%v\n", string(u))
}

func healthcheck(db *sql.DB, redis *redis.Client) string {
  var status, database, cache string

  // Check database connection
  if err := db.Ping(); err != nil {
    fmt.Printf("db.Ping() error: %v\n", err)
    database = "error"
  } else {
    database = "ok"
  }

  // Check cache connection
  if _, err := redis.Ping(ctx).Result(); err != nil {
    fmt.Printf("db.Ping() error: %v\n", err)
    cache = "error"
    } else {
    cache = "ok"
  }

  // Check status
  if database == "ok" && cache == "ok" {
    status = "ok"
  } else {
    status = "degraded"
  }

  u, err := json.Marshal(
    Health{
      Status: status,
      Database: database,
      Cache: cache,
    })

  if err != nil {
      panic(err)
  }

  return fmt.Sprintf("%v\n", string(u))
}

func increment_visits_counter(rc *redis.Client, path string) {
 	_, err := rc.Incr(ctx, fmt.Sprintf("page_visits_%s", path)).Result()
	if err != nil {
		fmt.Println(err)
	}

 	_, err = rc.Incr(ctx, fmt.Sprintf("page_visits_total")).Result()
	if err != nil {
		fmt.Println(err)
	}
}

func stats(rc *redis.Client) string {
	pattern := "page_visits_*"
	keys, err := rc.Keys(ctx, pattern).Result()
	if err != nil {
		fmt.Printf("Could not fetch keys: %v", err)
	}

	var visits []PageVisits

	for _, key := range keys {
		val, err := rc.Get(ctx, key).Result()
		if err != nil {
			fmt.Printf("Could not fetch value for key %s: %v", key, err)
			continue
		}
		visits = append(visits, PageVisits{Key: key, Value: val})
	}

	jsonData, err := json.Marshal(visits)
	if err != nil {
		fmt.Printf("Could not convert to JSON: %v\n", err)
	}

	return fmt.Sprintf(string(jsonData))
}

func pgstats(db *sql.DB) string {
  rows, err := db.Query("SELECT COALESCE(usename, ''), COALESCE(datname, ''), client_addr, COALESCE(state, '') FROM pg_stat_activity;")
  if err != nil {
    fmt.Println(err)
  }
  defer rows.Close()

  var pgstats []PgStats
  for rows.Next() {
      var usename, datname, client_addr, state string

      _ = rows.Scan(&usename, &datname, &client_addr, &state);

      if len(usename) == 0 {
        continue
      }
      pgstats = append(pgstats, PgStats{Username: usename, Database: datname, ClientAddr: client_addr, State: state})
  }

	jsonData, err := json.Marshal(pgstats)
	if err != nil {
		fmt.Printf("Could not convert to JSON: %v\n", err)
	}

	return fmt.Sprintf(string(jsonData))
}

func main() {
  mux := http.NewServeMux()

  // Connect to postgres
  psqlInfo := fmt.Sprintf("host=%s port=%s user=%s "+
    "password=%s dbname=%s sslmode=disable",
    host, port, user, password, dbname)

  db, err := sql.Open("postgres", psqlInfo)
  if err != nil {
    panic(err)
  }
  defer db.Close()

  // Connect to redis
  redisClient := redis.NewClient(&redis.Options{
    Addr:	  fmt.Sprintf("%s:%s", rhost, rport),
    Password: rpassword,
    DB:		  0,    
    Protocol: 2, 
  })
  defer redisClient.Close()

  // Routes
  mux.HandleFunc("/api/health", func(w http.ResponseWriter, r *http.Request) {
    logger(r)
    increment_visits_counter(redisClient, r.URL.Path)
    fmt.Fprintf(w, healthcheck(db, redisClient))
  })

  mux.HandleFunc("/api/stats", func(w http.ResponseWriter, r *http.Request) {
    logger(r)
    increment_visits_counter(redisClient, r.URL.Path)
    fmt.Fprintf(w, stats(redisClient))
  })

  mux.HandleFunc("/api/pgstats", func(w http.ResponseWriter, r *http.Request) {
    logger(r)
    increment_visits_counter(redisClient, r.URL.Path)
    fmt.Fprintf(w, pgstats(db))
  })

  mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    increment_visits_counter(redisClient, r.URL.Path)
    if r.URL.Path != "/" {
      errlogger(r)
      fmt.Fprintf(w, "Error 404")
    } else {
      logger(r)
      fmt.Fprintf(w, "Hi Koronet Team.")
    }
  })

  // Start the web server
  fmt.Println("Starting server on port 8000")
  err = http.ListenAndServe(":8000", mux)
  if err != nil {
    fmt.Printf("server error: %s\n", err)
    panic(err)
  }
}
