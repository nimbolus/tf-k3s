package common

import (
	"encoding/base64"
	"fmt"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"gopkg.in/yaml.v2"
)

func VerifyUserdata(t *testing.T, userdata string, k3sToken, k3sURL, k3sExec string) {
	userdataYAML := make(map[string]interface{})
	err := yaml.Unmarshal([]byte(userdata), &userdataYAML)
	assert.NoError(t, err)

	writeFiles, ok := userdataYAML["write_files"]
	assert.True(t, ok, "write_files not included in user_data")

	writeFilesSlice, ok := writeFiles.([]interface{})
	assert.True(t, ok, "write_files must be an array")

	firstFile := writeFilesSlice[0].(map[interface{}]interface{})
	content, ok := firstFile["content"]
	assert.True(t, ok, "write_files.file must have a key 'content'")

	decoded, err := base64.StdEncoding.DecodeString(content.(string))
	assert.NoError(t, err)
	assert.Contains(t, strings.Split(string(decoded), "\n"), fmt.Sprintf("K3S_TOKEN=%s", k3sToken))
	assert.Contains(t, strings.Split(string(decoded), "\n"), fmt.Sprintf("K3S_URL=%s", k3sURL))
	assert.Contains(t, strings.Split(string(decoded), "\n"), fmt.Sprintf("INSTALL_K3S_EXEC=\"%s\"", k3sExec))
}
