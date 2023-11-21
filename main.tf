resource "local_file" "pet" {
filename = "/root/pets.txt"
content = "My cat is MR.Cat"
}
resource "random_pet" "mypet" {
prefix = "MR"
separator = "."
length = "1"
}
