#Chewbacca: The compute instance—your first reproducible node.
resource "google_compute_instance" "chewbacca_vm" {
  name         = "chewbacca-web-server"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"

    access_config {} # External IP
  }

  # service_account {} block is left out as it is unneeded for now
  # NOTE: the console wizard does by default add the default GCE SA with fairly broad permissions

  metadata = {
    #Chewbacca: The banner is identity. Make it yours.
    student_name = "aaron-mcdonald"
    startup-script = file("./startup-test.sh")
  }

}






