# Create a new tag
resource "digitalocean_tag" "cluster_tag" {
  name = "${var.cluster_tag}"
}

# Upload SSH key which all instances will use.
resource "digitalocean_ssh_key" "default" {
  name       = "SSH Key for Terraform"
  public_key = "${file("${path.module}/../ssh/cluster.pem.pub")}"
}

# Create the bootstrap node
resource "digitalocean_droplet" "bootstrap_node" {
  image              = "${var.image}"
  name               = "bootstrap-node"
  region             = "${var.region}"
  size               = "${var.droplet_size}"
  ssh_keys           = ["${digitalocean_ssh_key.default.id}"]
  tags               = ["${digitalocean_tag.cluster_tag.id}"]
  private_networking = true

  connection {
    type        = "ssh"
    private_key = "${file("${path.module}/../ssh/cluster.pem")}"
    user        = "root"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y install git build-essential",
      "sudo apt-get install -qq python2.7 && ln -s /usr/bin/python2.7 /usr/bin/python",
      "git clone https://github.com/swade1987/hands-on-with-kubernetes-workshop.git",
    ]
  }
}

# Create the Kubernetes master nodes (e.g. master1)
resource "digitalocean_droplet" "master_nodes" {
  count              = "${var.master_count}"
  image              = "${var.image}"
  name               = "${format("master%1d", count.index + 1)}"
  region             = "${var.region}"
  size               = "${var.droplet_size}"
  ssh_keys           = ["${digitalocean_ssh_key.default.id}"]
  tags               = ["${digitalocean_tag.cluster_tag.id}"]
  private_networking = true
}

# Create the Kubernetes Etcd nodes (e.g. etcd1)
resource "digitalocean_droplet" "etcd_nodes" {
  count              = "${var.etcd_count}"
  image              = "${var.image}"
  name               = "${format("etcd%1d", count.index + 1)}"
  region             = "${var.region}"
  size               = "${var.droplet_size}"
  ssh_keys           = ["${digitalocean_ssh_key.default.id}"]
  tags               = ["${digitalocean_tag.cluster_tag.id}"]
  private_networking = true
}

# Create the Kubernetes worker nodes (e.g. worker1)
resource "digitalocean_droplet" "worker_nodes" {
  count              = "${var.worker_count}"
  image              = "${var.image}"
  name               = "${format("worker%1d", count.index + 1)}"
  region             = "${var.region}"
  size               = "${var.droplet_size}"
  ssh_keys           = ["${digitalocean_ssh_key.default.id}"]
  tags               = ["${digitalocean_tag.cluster_tag.id}"]
  private_networking = true
}
