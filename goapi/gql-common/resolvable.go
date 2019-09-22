package gqlcommon

import (
	"context"
	"github.com/graphql-go/graphql"
)

type Resolvable interface {
	GetAll() graphql.FieldResolveFn
	Get() graphql.FieldResolveFn
	GetByIds(ctx context.Context, ids []string) (interface{}, error)
	GetById(ctx context.Context, id string) (interface{}, error)
}
