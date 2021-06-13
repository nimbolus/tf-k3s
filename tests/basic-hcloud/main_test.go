package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/nimbolus/tf-k3s/tests/common"
	"github.com/stretchr/testify/assert"
)

func TestK3sBasic(t *testing.T) {
	t.Parallel()

	vars := map[string]interface{}{}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/basic-hcloud",
		Vars:         vars,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	k3sToken := terraform.Output(t, terraformOptions, "cluster_token")
	serverIP := terraform.Output(t, terraformOptions, "server_ip")

	k3sURL := terraform.Output(t, terraformOptions, "k3s_url")
	assert.Equal(t, fmt.Sprintf("https://%s:6443", serverIP), k3sURL)

	k3sServerUserdata := terraform.Output(t, terraformOptions, "server_user_data")
	common.VerifyUserdata(t, k3sServerUserdata, k3sToken, "", "server --disable traefik --node-label az=ex1")

	k3sAgentUserdata := terraform.Output(t, terraformOptions, "agent_user_data")
	common.VerifyUserdata(t, k3sAgentUserdata, k3sToken, k3sURL, "agent --node-label az=ex1")

	k3sExternalURL := terraform.Output(t, terraformOptions, "k3s_external_url")
	common.VerifyK8sAPI(t, k3sExternalURL)
}
