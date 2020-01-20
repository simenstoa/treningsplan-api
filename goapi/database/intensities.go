package database

import (
	"context"
	"goapi/logger"
	"goapi/models"
)

type intensityClient interface {
	GetIntensities(ctx context.Context) ([]models.Intensity, error)
}

func (c *client) GetIntensities(ctx context.Context) ([]models.Intensity, error) {
	log := logger.FromContext(ctx)

	sqlStatement := `SELECT intensity_uid, name, description, coefficient FROM Intensity;`

	rows, err := c.db.Query(sqlStatement)
	if err != nil {
		log.WithError(err).Error("Error querying db")
		return []models.Intensity{}, err
	}
	defer func() {
		err := rows.Close()
		if err != nil {
			log.WithError(err).Error("Error closing db query connection")
		}
	}()

	var intensities []models.Intensity
	for rows.Next() {
		var intensity models.Intensity
		err = rows.Scan(&intensity.Id, &intensity.Name, &intensity.Description, &intensity.Coefficient)
		if err != nil {
			log.WithError(err).Error("Error while parsing db row")
			return []models.Intensity{}, err
		}
		intensities = append(intensities, intensity)
	}
	// get any error encountered during iteration
	err = rows.Err()
	if err != nil {
		log.WithError(err).Error("Error while parsing db rows")
		return []models.Intensity{}, err
	}

	return intensities, nil
}

