let
  dylan = "age1yfjdtrxss3fpe6ruahu6dmjd654e0457dxlznzpe7fqn70gx6prq3946av"; # Replace with your actual public key from age-keygen -y
in
{
  "photoprismEnv.age".publicKeys = [ dylan ];
}

