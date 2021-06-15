package common

import (
	"context"
	"crypto/tls"
	"fmt"
	"io/ioutil"
	"net/http"
	"testing"

	"github.com/avast/retry-go"
	"github.com/stretchr/testify/assert"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

func WriteTempKubeconfig(kubeconfig string) (string, error) {
	kubeconfigFile, err := ioutil.TempFile("", "kubeconfig")
	if err != nil {
		return "", err
	}

	if _, err := kubeconfigFile.Write([]byte(kubeconfig)); err != nil {
		return "", err
	}
	return kubeconfigFile.Name(), kubeconfigFile.Close()
}

func VerifyK8sAPIAnonymous(t *testing.T, k3sURL string) {
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

func VerifyK8sAPIKubeconfig(t *testing.T, kubeconfig string) {
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	assert.NoError(t, err)

	client, err := kubernetes.NewForConfig(config)
	assert.NoError(t, err)

	err = retry.Do(
		func() error {
			_, err := client.ServerVersion()
			return err
		},
		retry.Attempts(15),
	)
	assert.NoError(t, err)
}

func VerifyK8sNodes(t *testing.T, kubeconfig string, nodeCount int) {
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	assert.NoError(t, err)

	client, err := kubernetes.NewForConfig(config)
	assert.NoError(t, err)

	err = retry.Do(
		func() error {
			nodes, err := client.CoreV1().Nodes().List(context.Background(), metav1.ListOptions{})
			if err != nil {
				return err
			}
			ready := 0
			for _, node := range nodes.Items {
				if NodeIsReady(&node) {
					ready++
				}
			}
			if ready < nodeCount {
				return fmt.Errorf("only %d nodes are ready (expected %d)", ready, nodeCount)
			}
			return nil
		},
		retry.Attempts(15),
	)
	assert.NoError(t, err)
}

func NodeIsReady(node *corev1.Node) bool {
	var cond corev1.NodeCondition
	for _, c := range node.Status.Conditions {
		if c.Type == corev1.NodeReady {
			cond = c
			break
		}
	}

	return cond.Status == corev1.ConditionTrue
}
