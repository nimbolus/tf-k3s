package test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/nimbolus/tf-k3s/tests/common"
	"github.com/stretchr/testify/assert"
)

func TestK3sHA(t *testing.T) {
	t.Parallel()

	vars := map[string]interface{}{
		"availability_zone": os.Getenv("OPENSTACK_AZ"),
		"network_id":        os.Getenv("OPENSTACK_NETWORK_ID"),
		"subnet_id":         os.Getenv("OPENSTACK_SUBNET_ID"),
		"floating_ip_pool":  os.Getenv("OPENSTACK_FLOATING_IP_POOL"),
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/ha-openstack",
		Vars:         vars,
	})

	terraform.InitAndApply(t, terraformOptions)

	k3sToken := terraform.Output(t, terraformOptions, "cluster_token")
	serverIP := terraform.Output(t, terraformOptions, "server_ip")

	k3sURL := terraform.Output(t, terraformOptions, "k3s_url")
	assert.Equal(t, fmt.Sprintf("https://%s:6443", serverIP), k3sURL)

	k3sServerUserdata := terraform.Output(t, terraformOptions, "server_user_data")
	common.VerifyUserdata(t, k3sServerUserdata, k3sToken, "", fmt.Sprintf("server --cluster-init --kube-apiserver-arg=\"enable-bootstrap-token-auth\" --disable traefik --node-label az=%s", vars["availability_zone"]))

	// k3sExternalURL := terraform.Output(t, terraformOptions, "k3s_external_url")
	common.VerifyK8sAPIAnonymous(t, k3sURL) // should use external

	kubeconfig := terraform.Output(t, terraformOptions, "kubeconfig")
	kubeconfigFile, err := common.WriteTempKubeconfig(kubeconfig)
	assert.NoError(t, err)
	defer os.Remove(kubeconfigFile)

	common.VerifyK8sAPIKubeconfig(t, kubeconfigFile)
	common.VerifyK8sNodes(t, kubeconfigFile, 4)

	if !t.Failed() {
		terraform.Destroy(t, terraformOptions)
	}
}
