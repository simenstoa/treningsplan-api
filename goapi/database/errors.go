package database

import "github.com/pkg/errors"

type EntityNotFound error

func newEntityNotFoundError(err error) EntityNotFound {
	return errors.WithMessage(err, "The entity was not found")
}
