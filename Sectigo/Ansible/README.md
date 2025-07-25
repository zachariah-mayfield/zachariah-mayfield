## Requirements
"KeyTool installed on your automation server."
"Ansible2.9 or higher"
"Sectigo API endpoint and Credentials"

```yaml

alias_name: "Cert_Alias_Name"

hostnames:
    - hostname1
    - hostname2
    - hostname3

domain_names:
    - Development.company-domain.com
    - UAT.company-domain.com
    - Production.company-domain.com

requestor:
    - "Your-Email_Address"

# Development
cert_type: 11111
org_id: 22222

# UAT
cert_type: 33333
org_id: 44444

# Production
cert_type: 55555
org_id: 66666

customer_URI: "Company-Domain-Name"

alias_name: the common name for the certificate
hostnames: list of hostnames the certificate will be tied to.
domain_name1: domain name 1
domain_name2: domain name 2
dn_ST: State
dn_L: City
dn_O: Organization Name
dn_OU: Organizational Unit
requestor: Email Address
certificate_file_name:
private_key_file_name: 
password_file_name:
csr_file_name:
enroll_data_file_name:

- name: Unencrypt private key
  ansible.builtin.command:
    cmd: "open rsa -in {{ cert_artifacts_dir_path }}/{{ private_key_file_name }} -out {{ cert_artifacts_dir_path }}/unencrypted_{{ private_key_file_name }} -passin pass: {{ password contents}}"

```