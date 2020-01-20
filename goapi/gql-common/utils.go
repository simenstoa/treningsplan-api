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

func GetStringArgument(p graphql.ResolveParams, key string) (string, error) {
	id, exist := p.Args[key]
	if !exist {
		return "", errors.New(key + " not found")
	}

	return id.(string), nil
}

func GetIntArgument(p graphql.ResolveParams, key string) (int, error) {
	val, ok := p.Args[key].(int)
	if !ok {
		return 0, nil
	}

	return val, nil
}