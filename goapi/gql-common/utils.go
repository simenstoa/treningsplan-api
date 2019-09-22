package gqlcommon

import (
	"errors"
	"github.com/graphql-go/graphql"
)

func GetId(p graphql.ResolveParams) (string, error) {
	id, exist := p.Args["id"]
	if !exist {
		return "", errors.New("id not found")
	}

	return id.(string), nil
}
