resource "local_file" "pet" {
    filename = "/pets.txt"
    content = "MY cat is MR.CAT"
    lifecycle {
      create_before_destroy = true
    }
  
}