package responsewriter

import (
	"context"
	"encoding/json"
	"goapi/logger"
	"goapi/server/problems"
	"net/http"

	"github.com/pkg/errors"
)

// Remember to return from your handler right afterwards. Otherwise more data might be written in the response.
func AbortHandler(w http.ResponseWriter) func(context.Context, problems.Problem) {
	return func(ctx context.Context, problem problems.Problem) {
		select {
		case <-ctx.Done(): // Context was cancelled or reached deadline
			log := logger.FromContext(ctx)
			log.Info("tried to write error response, but context was cancelled/reached deadline")
		default:
			response := problems.NewErrorResponse(ctx, problem)
			writeErrorResponse(ctx, w, response)
		}
	}
}

func writeErrorResponse(ctx context.Context, w http.ResponseWriter, response problems.ErrorResponse) {
	log := logger.FromContext(ctx)

	log.WithFields(logger.LogProblem(response.Error.Type, response.Error.StatusCode)).Warn("Aborted")

	body, err := json.Marshal(response)
	if err != nil {
		log.WithError(err).Error("Marshalling a response object to JSON failed.")

		w.WriteHeader(response.Error.StatusCode)
		_, err = w.Write([]byte(errors.Wrap(err, "while marshalling json").Error()))
		if err != nil {
			log.WithError(err).Error("Writing abort error body failed.")
		}
		return
	}

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(response.Error.StatusCode)
	_, err = w.Write(body)
	if err != nil {
		log.WithError(err).Error("Writing abort body failed.")
	}
}
