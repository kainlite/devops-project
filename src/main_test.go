package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	miniredis "github.com/alicebob/miniredis/v2"
	_ "github.com/lib/pq"
	"github.com/redis/go-redis/v9"
)

// MockRedis sets up a mock Redis instance for testing.
func MockRedis() *redis.Client {
	mr, err := miniredis.Run()
	if err != nil {
		panic(err)
	}

	client := redis.NewClient(&redis.Options{
		Addr: mr.Addr(),
	})

	return client
}

// MockDB sets up a mock PostgreSQL instance for testing.
func MockDB() *sql.DB {
	db, err := sql.Open("postgres", "postgres://postgres:postgres@localhost/postgres?sslmode=disable")
	if err != nil {
		panic(err)
	}
	return db
}

// TestHealthcheck tests the healthcheck function.
func TestHealthcheck(t *testing.T) {
	mockDB := MockDB()
	defer mockDB.Close()
	mockRedis := MockRedis()
	defer mockRedis.Close()

	result := healthcheck(mockDB, mockRedis)
	var health Health
	err := json.Unmarshal([]byte(result), &health)
	if err != nil {
		t.Fatalf("Expected valid JSON output, got error: %v", err)
	}

	if health.Status != "degraded" && health.Status != "ok" {
		t.Errorf("Unexpected health status: %v", health.Status)
	}
}

// TestIncrementVisitsCounter tests the increment_visits_counter function.
func TestIncrementVisitsCounter(t *testing.T) {
	mockRedis := MockRedis()
	defer mockRedis.Close()

	path := "/test-path"
	increment_visits_counter(mockRedis, path)

	count, err := mockRedis.Get(context.Background(), fmt.Sprintf("page_visits_%s", path)).Result()
	if err != nil {
		t.Fatalf("Failed to get page_visits for %s: %v", path, err)
	}

	if count != "1" {
		t.Errorf("Expected visit count to be 1, got %s", count)
	}
}

// TestStats tests the stats function.
func TestStats(t *testing.T) {
	mockRedis := MockRedis()
	defer mockRedis.Close()

	mockRedis.Set(context.Background(), "page_visits_/test1", "5", 0)
	mockRedis.Set(context.Background(), "page_visits_/test2", "10", 0)

	result := stats(mockRedis)
	var visits []PageVisits
	err := json.Unmarshal([]byte(result), &visits)
	if err != nil {
		t.Fatalf("Expected valid JSON output, got error: %v", err)
	}

	if len(visits) != 2 {
		t.Errorf("Expected 2 visits, got %d", len(visits))
	}
}

// TestHealthHandler tests the /api/health endpoint handler.
func TestHealthHandler(t *testing.T) {
	mockDB := MockDB()
	defer mockDB.Close()
	mockRedis := MockRedis()
	defer mockRedis.Close()

	req, err := http.NewRequest("GET", "/api/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, healthcheck(mockDB, mockRedis))
	})

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	var health Health
	err = json.Unmarshal(rr.Body.Bytes(), &health)
	if err != nil {
		t.Fatalf("Expected valid JSON output, got error: %v", err)
	}

	if health.Status != "ok" && health.Status != "degraded" {
		t.Errorf("Unexpected health status: %v", health.Status)
	}
}

// TestStatsHandler tests the /api/stats endpoint handler.
func TestStatsHandler(t *testing.T) {
	mockRedis := MockRedis()
	defer mockRedis.Close()

	mockRedis.Set(context.Background(), "page_visits_/test1", "5", 0)
	mockRedis.Set(context.Background(), "page_visits_/test2", "10", 0)

	req, err := http.NewRequest("GET", "/api/stats", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, stats(mockRedis))
	})

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	var visits []PageVisits
	err = json.Unmarshal(rr.Body.Bytes(), &visits)
	if err != nil {
		t.Fatalf("Expected valid JSON output, got error: %v", err)
	}

	if len(visits) != 2 {
		t.Errorf("Expected 2 visits, got %d", len(visits))
	}
}
