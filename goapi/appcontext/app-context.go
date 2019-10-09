package appcontext

import (
	"context"
	"golang.org/x/text/language"
	"strconv"
	"time"
)

type ContextKey int

const (
	LoggerKey ContextKey = iota

	CorrelationIdKey
	SessionIdKey
	CustomerIdKey
	DeviceIdKey
	HostAddressKey
	PathKey
	AppIdKey
	PlatformKey
	OsKey
	VippsAppVersionKey

	requestStartKey
	languageKey

	InvoiceIdKey
	InvoiceToAccountKey
	InvoiceHasKidKey
	InvoiceHasMessageKey
	InvoiceAmountKey
	InvoiceScheduledDateKey
	VippsInvoiceIdKey
	StorageBlobPathKey
	OperationKey
)

func WithCorrelationId(ctx context.Context, correlationId string) context.Context {
	return context.WithValue(ctx, CorrelationIdKey, correlationId)
}

func CorrelationId(ctx context.Context) string {
	if val, ok := ctx.Value(CorrelationIdKey).(string); ok {
		return val
	}
	return ""
}

func WithDeviceId(ctx context.Context, deviceId string) context.Context {
	return context.WithValue(ctx, DeviceIdKey, deviceId)
}

func WithPath(ctx context.Context, path string) context.Context {
	return context.WithValue(ctx, PathKey, path)
}

func WithHostAddress(ctx context.Context, hostAddress string) context.Context {
	return context.WithValue(ctx, HostAddressKey, hostAddress)
}

func WithSessionId(ctx context.Context, sessionId string) context.Context {
	return context.WithValue(ctx, SessionIdKey, sessionId)
}

func WithRequestStart(ctx context.Context, time time.Time) context.Context {
	return context.WithValue(ctx, requestStartKey, time)
}

func WithAppId(ctx context.Context, appId string) context.Context {
	return context.WithValue(ctx, AppIdKey, appId)
}

func RequestStart(ctx context.Context) time.Time {
	if val, ok := ctx.Value(requestStartKey).(time.Time); ok {
		return val
	}
	return time.Unix(0, 0)
}

func WithLanguage(ctx context.Context, lang language.Tag) context.Context {
	return context.WithValue(ctx, languageKey, lang)
}

func Language(ctx context.Context) language.Tag {
	if val, ok := ctx.Value(languageKey).(language.Tag); ok {
		return val
	}
	return language.Tag{}
}

func WithCustomerId(ctx context.Context, customerId string) context.Context {
	return context.WithValue(ctx, CustomerIdKey, customerId)
}

func WithPlatform(ctx context.Context, platform string) context.Context {
	return context.WithValue(ctx, PlatformKey, platform)
}

func Platform(ctx context.Context) string {
	if val, ok := ctx.Value(PlatformKey).(string); ok {
		return val
	}
	return ""
}

func WithOs(ctx context.Context, phoneOs string) context.Context {
	return context.WithValue(ctx, OsKey, phoneOs)
}

func WithVippsAppVersion(ctx context.Context, vippsAppVersion string) context.Context {
	return context.WithValue(ctx, VippsAppVersionKey, vippsAppVersion)
}

func VippsAppVersion(ctx context.Context) string {
	if val, ok := ctx.Value(VippsAppVersionKey).(string); ok {
		return val
	}
	return ""
}

func CustomerId(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	if val, ok := ctx.Value(CustomerIdKey).(string); ok {
		return val
	}
	return ""
}

func WithInvoice(ctx context.Context, id, toAccount string, hasKid, hasMessage bool, amount int32, scheduledDate time.Time) context.Context {
	ctx = WithInvoiceId(ctx, id)
	m := map[ContextKey]string{
		InvoiceToAccountKey:     toAccount,
		InvoiceHasKidKey:        strconv.FormatBool(hasKid),
		InvoiceHasMessageKey:    strconv.FormatBool(hasMessage),
		InvoiceAmountKey:        strconv.FormatInt(int64(amount), 10),
		InvoiceScheduledDateKey: scheduledDate.String(),
	}
	for key, val := range m {
		ctx = context.WithValue(ctx, key, val)
	}

	return ctx
}

func WithInvoiceId(ctx context.Context, invoiceId string) context.Context {
	return context.WithValue(ctx, InvoiceIdKey, invoiceId)
}

func WithVippsInvoiceId(ctx context.Context, vippsInvoiceId string) context.Context {
	return context.WithValue(ctx, VippsInvoiceIdKey, vippsInvoiceId)
}

func WithStorageBlobPath(ctx context.Context, storageBlobPath string) context.Context {
	return context.WithValue(ctx, StorageBlobPathKey, storageBlobPath)
}

func WithOperation(ctx context.Context, op operation) context.Context {
	return context.WithValue(ctx, OperationKey, string(op))
}
