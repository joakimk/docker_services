defmodule DockerServices.DockerImagesTest do
  use ExUnit.Case

  test "parsing a list of installed images" do
    data = """
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    redis               2.8.19              8c37ff647cf2        5 months ago        110.8 MB
    redis               2.8                 0ca571d528ac        6 months ago        110.8 MB
    memcached           1.4                 bbfde254e614        6 months ago        140.5 MB
    """

    list = DockerServices.DockerImages.parse(data)
    assert list == [ "redis:2.8.19", "redis:2.8", "memcached:1.4" ]
  end
end
