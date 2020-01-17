package problems

import (
	"context"
	"goapi/appcontext"
	"net/http"
)

const (
	errTypePrefix = "https://strides.no/problems/"

	genericErrorTitle = "An unexpected error occurred."
)

type ErrorResponse struct {
	Error Problem `json:"error"`
}

// Problem is the actual representation of the err/problem.
type Problem struct {
	Type          string `json:"type"`
	Title         string `json:"title"`
	CorrelationId string `json:"correlationId"`
	Detail        string `json:"detail,omitempty"`
	Instance      string `json:"instance,omitempty"`
	StatusCode    int    `json:"-"`
}

func NewErrorResponse(ctx context.Context, problem Problem) ErrorResponse {
	correlationId, err := appcontext.CorrelationId(ctx)
	if err != nil {
		problem.CorrelationId = appcontext.GenerateCorrelationId()
	} else {
		problem.CorrelationId = correlationId
	}

	return ErrorResponse{
		Error: problem,
	}
}

var (
	ErrInvalidAuthorizationToken = Problem{
		Type:       errTypePrefix + "invalid-authorization-token",
		Title:      "Not authorized.",
		StatusCode: http.StatusUnauthorized,
	}
)
