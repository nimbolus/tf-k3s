package common

import (
	"crypto/tls"
	"net/http"
	"testing"

	"github.com/avast/retry-go"
	"github.com/stretchr/testify/assert"
)

func VerifyK8sAPI(t *testing.T, k3sURL string) {
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	client := &http.Client{Transport: tr}

	err := retry.Do(
		func() error {
			_, err := client.Get(k3sURL)
			return err
		},
		retry.Attempts(30),
	)
	assert.NoError(t, err)
}
