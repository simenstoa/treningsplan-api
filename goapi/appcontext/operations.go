package appcontext

type operation string

const (
	// Request
	FullRequest operation = "fullRequest"

	// External calls
	FetchCustomerByIdOperation      operation = "extFetchCustomerById"
	CreateInvoiceWithRetry          operation = "extCreateVippsInvoiceWithRetry"
	CreateInvoice                   operation = "extCreateVippsInvoice"
	RevokeInvoiceWithRetry          operation = "extRevokeVippsInvoiceWithRetry"
	RevokeInvoice                   operation = "extRevokeVippsInvoice"
	FetchInvoice                    operation = "extFetchVippsInvoice"
	FetchVippsInvoiceAccessToken    operation = "extFetchVippsInvoiceAccessToken"
	FetchVippsInvoiceRecipientToken operation = "extFetchVippsInvoiceRecipientToken"

	// Cosmos
	CosmosCreateInvoice                operation = "cosmosCreateInvoice"
	CosmosCreateAttachment             operation = "cosmosCreateAttachment"
	CosmosFetchInvoice                 operation = "cosmosFetchInvoice"
	CosmosFetchInvoiceByVippsInvoiceId operation = "cosmosFetchInvoiceByVippsInvoiceId"
	CosmosFetchAttachment              operation = "cosmosFetchAttachment"
	CosmosReplaceInvoice               operation = "cosmosReplaceInvoice"
	CosmosCalcAmount                   operation = "cosmosCalcAmount"

	// Blob storage
	StorageUploadFile    operation = "storageUploadFile"
	StorageDownloadFile  operation = "storageDownloadFile"
	StorageFetchSasToken operation = "storageFetchSasToken"

	// Scanning
	ImageDimensionValidation operation = "scanImageDimensionValidation"
	ImageBinarization        operation = "scanImageBinarization"
	ImageGrayscaling         operation = "scanImageGrayscaling"
	AzureOCR                 operation = "scanAzureOcr"
	AzureRecognizeText       operation = "scanAzureRecognizeText"
	AzureRecognizeTextResult operation = "scanAzureRecognizeTextResult"
	FullScan                 operation = "scanFullScan"
	ShadowScan               operation = "scanShadowScan"

	// Payments
	GetPaymentSource operation = "getPaymentSource"
	PayInvoice       operation = "payInvoice"

	// Account/KID-service
	GetAccount  operation = "getAccount"
	ValidateKid operation = "validateKid"
	FilterKid   operation = "filterKid"
)
