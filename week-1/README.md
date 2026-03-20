# Class 7.5 / SEIR-1: Week 1 Summary notes

## Table of Contents
* [Introduction](#introduction)
* [Class Overview](#class-overview)
* [GCP Account Creation and Basic Setup](#gcp-account-creation-and-basic-setup)
* [Key Terminology](#key-terminology-in-simple-ish-terms)
* [GCP Console](#gcp-console)
* [Project Explanation](#project-explanation)
    * [Resource Hierarchy](#resource-hierarchy)
    * [Project Identifiers](#project-identifiers)
* [Global Infrastructure](#global-infrastructure)
    * [Service Scope](#service-scope)
    * [Naming Conventions](#naming-conventions)
* [Class Lab](#class-lab)
    * [Preliminaries](#preliminaries)
    * [Navigate to Compute Engine](#navigate-to-compute-engine)
* [Troubleshooting](#troubleshooting)
* [Startup script overview](#startup-script-overview)

---

## Introduction 
This week will be covering basic GCP account usage and one of the core services of GCP called the Compute Engine. The class will deploy a web server available on the public internet multiple times. We will cover automating the setup of the server using a process called bootstrapping (specifically with a startup script). 

## Class Overview
* Admin notes (watch recording for these please)
* GCP account creation (additional configuration is skipped, outlined in the install document)
* Create project and enable the needed API 
* Discuss the end goal

## GCP Account Creation and Basic Setup 
This is a requirement for class. The install document covers this in great detail. 

You will need a Gmail account, a debit/credit card and about 5 minutes (normally). You can create the account as a personal or organizational account (if you want me to say one, then choose organization). You can make up whatever info you want for the questions except the billing info. 

## Key Terminology (in simple-ish terms)
* **GCP Console** (or simply "the console"): The web interface for GCP.
* **Compute Engine:** The GCP service for making servers.
* **VM:** A virtual server (a server run on GCP's data center).
* **Server:** A computer that does things for other computers or devices. Examples are web servers (they host websites), file servers (they host files), a media server (many of you may use something like Plex at home), and many other types as well. 
* **IP Address:** The address to find a computer (such as a server). It is split into 4 "octets" such as 10.20.30.40 with the decimals. Each decimal number will be between 0–255 inclusive (it can be 0 or 255, such as 255.255.255.0). 
* **HTTP:** Hypertext Transport Protocol, which is the protocol websites were built on. Typically not used today in favor of HTTPS but used widely for testing. It uses the protocol "TCP" to transfer data and traditionally uses port 80 (it doesn't have to; often 8080 and 5000 are used for example). 
* **SSH:** Secure Shell protocol, which is a protocol that uses cryptographic keys to create a secure "tunnel" to another computer and allows you to access its shell and use the command line interface. 

## GCP Console

The GCP web console (normally we will just say "the console") is a web-based graphical user interface that is designed to allow easy and quick interaction with the Google Cloud Platform. In later classes, we will cover alternative means of interacting with GCP that are quicker and able to be automated. Using the Console as a way to administer GCP is known as **ClickOps**. 

Two important pages of the console you should thoroughly familiarize yourself with are:

* [Console Welcome page](https://console.cloud.google.com/welcome)
* [Console Dashboard](https://console.cloud.google.com/home/dashboard)

It is important to remember the console is highly uniform (GCP is a bit better at this than other platforms). What this means is when you go to different pages of the console, only what has to change actually changes. Notice when you go between the welcome page and the dashboard that a lot of the page that is displayed remains the same. This makes navigation fairly straightforward once you learn these aspects. 

![Welcome page](./assets/welcome.PNG)

In the above screenshot you can see (ignore what's in red, that's either part of the welcome page itself or not needed for a while):
* **A)** This is the navigation menu or typically just called the "hamburger menu." This is how we can move to different "services" (like Compute Engine or Cloud Storage) in GCP as we will see later in class. [This](./assets/hamburger.PNG) is the hamburger/navigation menu expanded fully.
    * *Note:* Mine will look slightly different. I have favorites. The top 4 will always be the same. 
* **B)** This is the project selector. You should make sure this is set to the project you created when you set up the GCP account. I will go into more detail below. 
* **C)** These are your notifications. Successful deployments of various services, alerts, errors, and more will be available here. 
* **D)** This is the settings menu. Payment methods, appearance of the console, documentation, and more can be accessed from this. 
* **E)** This is the identity you are using for GCP. For everyone right now this is simply your Gmail account you used to make the GCP account. If you have multiple Gmails signed in sometimes it will switch it to another and you will get a permissions error. So be mindful that you are signed in with the correct Gmail account. 
* **F)** This isn't displayed on every page but will be discussed further down. Please note that the project displayed matches the project selector. 
* **G)** This is the search bar. You can search for services and documentation from here. 
* **Star)** This is like your eject button if you get lost. It will take you back to the Welcome page. 

## Project Explanation
Projects are an abstraction of a group of resources, permissions, policies, and billing info within GCP. Effectively, a project is required for anything substantive in GCP. Also, if you have resources you are being billed for, you can look by project and shut down entire projects to end billing which is useful for tracking rogue resources. 

### Resource Hierarchy
They can be grouped into folders and organizations if you have multiple. 

See [here](https://docs.cloud.google.com/static/resource-manager/img/cloud-hierarchy.svg) for a hierarchy diagram from Google. This won't really apply to you for a while as for lab purposes one or two projects is plenty. You are allowed about 25 projects before a quota limit is hit. 

The service that is used to manage projects is called the "Resource Manager" and if you want to read about it in detail, the documentation is [here](https://docs.cloud.google.com/resource-manager/docs).

### Project Identifiers
If you refer back to the Console welcome page screenshot on letter **F**, you can see some info. Projects have 3 identifiers:

* **Project name:** This is basically a nickname. It is mutable (you can change it). It is not unique (you can reuse it and other GCP accounts can use it). It is basically for human readability. In my screenshot, it is "seir-1" and you can tell because the project picker displays it and it says "You're working in seir-1."
* **Project ID:** This is a lowercase string (text characters) with alphanumeric characters and hyphens/dashes permitted. It is required to be globally unique (no other project of yours or any other GCP user can use this ID). It is immutable (it can never be changed). It is a user-friendly unique project identifier that we will use in gcloud commands and with Terraform. You may have noted that my project ID is the same as my project name. This means when I created my account I chose a project name that had never been used before, otherwise GCP would have appended a hyphen and a random "pet name" and alphanumeric string at the end like "my-first-project-gorilla-4df6a". So my project ID *happens* to be the same as my project name, but for most of you this won't be the case. 
* **Project Number:** This is an auto-generated 12-digit number. It is globally unique and immutable. It is typically only used with Google support and for certain error messages. 

## Global Infrastructure
Services in GCP can be largely classified as Global, Regional, and Zonal. To define these terms we need to examine what the "cloud" really is and the actual infrastructure of GCP itself. 

1. Everything we do using GCP exists physically in a data center. It is simply not our data center. We lease software, compute, storage, networking, and other resources from Google and it is packaged in a way we can effectively use it. 
2. The GCP physical infrastructure exists physically in **zones**. Zones may or may not be geographically near each other but they have independent security, cooling, power, etc. 
3. Zones are grouped into **Regions**. Regions are comprised of at least 3 zones that are connected together so they can communicate very quickly. 
4. All regions are grouped together and would be the **global infrastructure** of GCP. 

There are some simplifications (there is additional network infrastructure, POPs, etc.) but for the time being this is a good explanation. 

Now exactly what makes up a zone? It is an actual data center where there are teams of plant engineers, electricians, HVAC techs, physical security, and much more staff. These zones have strict requirements for uptime, independent software updates, physical security using a variety of means (from security guards that work directly for Google to laser-based movement detection systems in hallways) to cybersecurity requirements (Google uses Titan, a proprietary hardware chip to detect if someone added unauthorized hardware to a server or tampered with it for example) to many compliance requirements (PCI DSS for example).

### Service Scope
* **Zonal Services:** These services "live" in a single zone. An example of this is a "Zonal Persistent Disk" which is just Google's way of saying a hard drive basically. Hard Drives are physical things so they have to exist in a zone. We typically call "Persistent Disks" simply **PDs**. If you see "PD" by itself you would assume it's zonal. 
* **Regional Services:** These services "live" in a region which means they live in one or more zones within said region. To continue the earlier example, an example of a regional service is a "Regional Persistent Disk." Earlier we discussed that zones run PDs since hard drives are physical things. However if that hard drive in one zone fails then we lose our data. So instead we can use a Regional PD which finds two hard drives in the Region (each one in a different zone) and copies your data to each one. This way if one drive fails, your infrastructure is unaffected.
* **Global Services:** These services are available in any region. A good example of this is the "Secrets Manager." Once a password is in Secrets Manager, we can access it from any region. 

### Naming Conventions
* **Regions:** `[Geography]-[direction/area][number]`
    * Geography: continent or landmass (us, europe, asia, australia, etc)
    * Direction/area: west, east, central, southeast, etc
    * Number: One through the low teens.
    * `us-central1` (Iowa) is the largest by zones. 
    * `us-east1` (South Carolina) and `europe-west1` (Belgium) have the newest features. 
* **Zones:** A zone is identified by the region with a hyphen and letter appended. 
    * `us-central1-c`
    * `us-west4-a`
    * *Note:* Don't assume every region uses zonal letters a, b, and c. 

---

## Class Lab 

We are going to be making a web server that is hosted on GCP today. We have the script (a list of commands that the server will run right after booting) to set it up. 

### Preliminaries 
We will be using the Compute Engine today for the lab to create a VM. A **VM** is a "virtual machine" because in the GCP data centers a technology called virtualization is used to allow multiple computers to run on a single set of hardware. We will use our VM as a **server**, meaning it will serve others by running jobs or hosting content. 

### Navigate to Compute Engine 
1. Start at the Console Welcome page. 
2. Go to the **Hamburger Menu**.
3. Hover over **Compute Engine**.
4. In the second menu, click on **VM Instances**. [Example here](./assets/gce-menu.PNG).
5. If you get a message about your API not being enabled, simply enable it and wait a minute. 
6. Click on **Create Instance** in the upper left. [Example here](./assets/gce-create-instance.PNG).
7. [This](./assets/create-instance-menu.PNG) is what you will see on the left.
8. **Machine Configuration menu:**
    * **Name:** An easy identifier for your VM.
    * **Region and Zone:** Choose a zone (e.g., `us-central1-a`).
    * **Machine Type:** E2 is the cheapest and works perfectly. 
9. **OS and storage:** Here we can change the Operating system (default is Debian Linux). 
10. **Networking:** * Under firewall, check **Allow HTTP traffic**. [Example here](./assets/instance-network-settings.PNG). 
    * This allows `tcp:80` traffic to enter (ingress) so people can see your website. 
11. **Advanced:** * Under **Automation**, fill in the **Startup script**. 
    * When using GitHub, make sure you use the **raw copy** button. 
    * Simple script example [here](./scripts/simple-start-up.sh).
12. Press the **Create** button. 
13. Wait 1–5 minutes for the VM to boot and bootstrap.
14. Click on the **External IP** to test your website. [Example here](/assets/external-ip.png).

## Troubleshooting
* Is Port 80 reachable? Verify the network tag. 
* Check metadata keys to verify the startup script. 
* Verify the correct External IP is used.
* Try a different browser. 
* Ensure `http://` (not `https://`) is used in the URL bar. 


## Startup script overview

The scripts can seem complex which is why I kept mine simple. Basically the big steps are:
1) If needed, download needed software onto the VM (like a webserver or packages for python)
2) Make or download an HTML file 
3) Use a web server to run a web server 

Thats what the scripts at a very high overview. 

For example mine:
1) line 1 is simply telling the VM its a shell script to be ran with the bash shell. This is the program that understands what the script says. 
2) I skip downloading packages using something like `apt` since my script doesnt have any "dependencies" (everything is already on the VM from the beginning). 
3) line 4-6 I get some metadata (data about the VM server itself) and save it to variables (those are in caps).
4) lines 9-18 I make a super simple html file for the webpage and put the metadata inside it. 
5) line 21 I use python's built in web server module to run the web page. 

This script is super simple and unrealistic for production but hopefully it helps you understand what is happening. 

The webpage of my script will look like this:
![](./assets/script-output.PNG)