package mw

import (
	"github.com/gorilla/mux"
	"goapi/appcontext"
	"goapi/logger"
	"net/http"
	"time"
)

func TrackRequestStart() mux.MiddlewareFunc {
	return func(handler http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			handler.ServeHTTP(w, r.WithContext(appcontext.WithRequestStart(r.Context(), time.Now())))
		})
	}
}

func TrackRequestFinish() mux.MiddlewareFunc {
	return func(handler http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := r.Context()
			ctx = appcontext.WithOperation(ctx, appcontext.FullRequest)
			log := logger.FromContext(ctx)

			handler.ServeHTTP(w, r)

			duration := time.Since(appcontext.RequestStart(r.Context()))
			log.
				WithFields(logger.LogDuration(duration)).
				Info("Full request: ", duration)
		})
	}
}
