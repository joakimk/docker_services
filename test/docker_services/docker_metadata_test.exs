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
    # assert metadata.external_port == TODO
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
