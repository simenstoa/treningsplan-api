package mw

import (
	"goapi/appcontext"
	"goapi/appcontext/initctx"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/sirupsen/logrus"
)

func InitContext() mux.MiddlewareFunc {
	return func(handler http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx, cancel := initctx.InitializeContext(r.Context(), logrus.Fields{"is_request": true})
			defer cancel()

			updatedReq := r.WithContext(ctx)
			updatedReq = updatedReq.WithContext(appcontext.WithCorrelationId(updatedReq.Context(), appcontext.GenerateCorrelationId()))
			updatedReq = updatedReq.WithContext(appcontext.WithPath(updatedReq.Context(), r.URL.Path))

			handler.ServeHTTP(w, updatedReq)
		})
	}
}
