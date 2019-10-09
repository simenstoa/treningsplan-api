package initctx

import (
	"context"
	"goapi/appcontext"
	"goapi/logger"

	"github.com/sirupsen/logrus"
)

func InitializeContext(baseContext context.Context, contextFields logrus.Fields) (context.Context, context.CancelFunc) {
	ctx, cancel := context.WithCancel(baseContext)
	log := appcontext.LogFactory(contextFields)
	ctx = logger.ContextWithLogger(ctx, log)
	return ctx, cancel
}
