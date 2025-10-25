let

  mystreamer = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIu3vp9KAi2STO1cO6Sre1ly7CjCCmD47BF3/WK6G6hpJTr8awk60gjpBo8VfqljZA8geN4kUiWmxp0HhjR0WD8xf/1ssPK3yXe5dL3OMhu7/LhFxhBPEuloB7sBxOALE5fy2DlcDFFeK3XrJuN3EE3TJEXuJxq1j6L5DohwE8soMUwvjT4I4MlBGMDTiuhtG5n4ZKPWthCQUf9+4ga/+ZsuzISVLiaxsioAouuAUoilBsgoMZ2nrdzEBbn01ssPYoJjvAO0MtqzOrKq9e+EsdJW/Ft5dgzG7ViiVg/h3giVv3TT+djSybUCqUBOWvH+tywI5PSCj87aKES4KtB7Id";

  ephem = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNFlOPT4uttGPdQBq6wK/4jRuQ64qNm1GJ7K75XeKuY root@ephem";

  allKeys = [ ephem mystreamer ];
in
{
  "photoprismEnv.age".publicKeys = allKeys;
  "openaiApiKey.age".publicKeys = allKeys;
  "cloudflaredCreds.age".publicKeys = allKeys;
}

