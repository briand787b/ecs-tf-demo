package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "ENV: ", os.Getenv("ENV"))

		w.WriteHeader(200)
	})

	log.Fatal(http.ListenAndServe(":80", nil))
}
