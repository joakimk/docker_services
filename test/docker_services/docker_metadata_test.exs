defmodule DockerServices.DockerMetadataTest do
  use ExUnit.Case

  test "extracts metadata" do
    metadata = DockerServices.DockerMetadata.build(
    """
    [{
        "Config": {
            "ExposedPorts": {
                "6379/tcp": {}
            },
            "Volumes": {
                "/data": {}
            }
        }
    }]
    """)

    assert metadata.internal_port == 6379
    assert metadata.volumes == [ "/data" ]
  end

  test "extracts external_port when available" do
    metadata = DockerServices.DockerMetadata.build(
    """
    [{
        "Config": {
            "ExposedPorts": {
                "6379/tcp": {}
            }
        },
        "NetworkSettings": {
          "Ports": {
            "6379/tcp": [
              {
                  "HostIp": "0.0.0.0",
                  "HostPort": "32776"
              }
            ]
          }
        }
    }]
    """)

    assert metadata.external_port == 32776
  end

  test "handles missing volume data" do
    metadata = DockerServices.DockerMetadata.build(
    """
    [{
        "Config": {
            "ExposedPorts": {
                "6379/tcp": {}
            }
        }
    }]
    """)

    assert metadata.volumes == []
  end
end
