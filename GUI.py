import PySimpleGUI as sg
import os


title_font = ("Helvetica", 15)
button_font = ("Helvetica", 20)

col1=[[sg.Text("GENERAL", font=title_font, pad=15)],
[sg.Text("Project Name", tooltip="Name of the project. Only alphanumerical characters."), sg.Input('',size=(20,1), key = "input_project_name")],
[sg.Text("Region", tooltip="Region in which the infrastructure will be deployed. Displayed in AWS internal nomenclature."), sg.Combo(['us-east-1', 'us-east-2', 'us-west-1', 'us-west-2', 'af-south-1', 'ap-east-1', 'ap-southeast-3','ap-south-1','ap-northeast-3','ap-northeast-2','ap-southeast-1','ap-southeast-2','ap-northeast-1','ca-central-1','eu-central-1','eu-west-1', 'eu-west-2','eu-south-1','eu-west-3','eu-north-1','me-south-1','sa-east-1'], default_value="eu-west-1", size=(15,1), key = "input_region")],
[sg.Text("Profile", tooltip="name of the AWS profile that contains your AWS credentials (must be located in ~/.aws/credentials.)"), sg.Input('',size=(15,1), key = "input_profile")],

[sg.Text("DATABASE", font=title_font, pad=15)],
[sg.Radio("RDS", "db_type", default = True, key = "db_rds", enable_events=True), sg.Radio("Aurora", "db_type", default = False, key = "db_aurora", enable_events=True)],
[sg.Text("Instance Type", tooltip="Type of database instance. Remember that AWS database instances always have the prefix db (ex. db.t3.small) and that db.t3.micro is not allowd if aurora cluster is used."), sg.Input('',size=(10,1), key = "input_db_instance")],
[sg.Text("Database Storage (in GB)", tooltip="Database storage is not used in aurora clusters because aurora service manages storage size itself. If you use RDS, storage can scale up to 10 times the value you put here.", key="text_db_storage"), sg.Spin([i for i in range(5, 100)], initial_value=10, size=(2, 1), enable_events=True, key='db_storage')],
[sg.Checkbox("Database Backups", tooltip="Recommended in most projects. Backups in Aurora are automatically enabled", disabled = False, default=False, size=(20,1), key = "input_db_backups")],
[sg.Checkbox("Database Encryption", tooltip="Probably a project requirement", default=False, size=(20,1), key = "input_db_encrypted")],

[sg.Text("ELASTICACHE", font=title_font, pad=15)],
[sg.Radio("Memcached", "engine_elasticache", default = True, key = "memcached_elasticache", enable_events=True), sg.Radio("Redis", "engine_elasticache", default = False, key = "redis_elasticache", enable_events=True)],
[sg.Text("Instance Type", tooltip="Type of elasticache instance. Remember that AWS elasticache instances always have the prefix cache (ex. cache.t3.micro)."), sg.Input('',size=(10,1), key = "input_elasticache_instance")],
[sg.Checkbox("Cluster Mode", tooltip="Cluster mode only works with redis. It enables you to have two primary databases (instances that read and write), each one with its read replicas.", default=False, disabled=True, size=(20,1), key = "input_cluster")],   
[sg.Text("Number of read replicas", tooltip="If your application is read intensive you should consider this option."), sg.Spin([i for i in range(0, 6)], initial_value=1, size=(2, 1), enable_events=True, key='db_rr_number')],  
[sg.Checkbox("Elasticache Encryption", tooltip="Only supported by Redis. Encryption at rest, not in transit.", default=False, disabled=True, size=(20,1), key = "input_elasti_encrypted")]]  


col2=[[sg.Text("AUTOSCALING", font=title_font, pad=15)],
[sg.Checkbox("Spot", default=False, size=(10,1), key = "input_spot", tooltip="Spot instances can reduce up to 90%\ of your on-demand price. However they can be removed at any time, so it is not recommended for constant stateful workloads "), sg.Text("Spot Price"), sg.Input('',size=(10,1), key = "input_spot_price")],
[sg.Text("Instance Type", tooltip="Type of EC2 instance (ex. t3.large)."), sg.Input('',size=(10,1), key = "input_instance")],
[sg.Text("Max Number of instances", tooltip="Upper threshold of the scaling group."), sg.Spin([i for i in range(2, 10)], initial_value=4, size=(2, 1), enable_events=True, key='max_instances')],
[sg.Text("Min Number of instances", tooltip="Lower threshold of the scaling group."), sg.Spin([i for i in range(2, 10)], initial_value=2, size=(2, 1), enable_events=True, key='min_instances')],
[sg.Text("Create a new instance when general CPU usage is above"), sg.Spin([i for i in range(51, 96)], initial_value=85, size=(2, 1), enable_events=True, key='cpupolicyscaleup'), sg.Text("%")],
[sg.Text("Delete an existing instance when general CPU usage is below"), sg.Spin([i for i in range(6, 50)], initial_value=25, size=(2, 1), enable_events=True, key='cpupolicyscaledown'),sg.Text("%")],

[sg.Text("CLOUDFRONT", font=title_font, pad=15)],
[sg.Text("Cloudfront Blacklist", tooltip="Subset of the most blacklisted countries in the ISO 3166 Country Code format"), sg.Listbox(["AF","BY","BR","CA","CN","FR","DE","HK","IR","IQ","IL","JP","KP","KR","MX","NG","PK","PS", "QA","RU","SA","ES", "UA", "US", "VE"], size=(15,5), key = "cloudfornt_blacklist", select_mode=sg.LISTBOX_SELECT_MODE_MULTIPLE)]]

col3=[[sg.Text("DNS", font=title_font, pad=15)],
[sg.Text("Domain Name", tooltip="The AWS registered domain name of your project. Introduce the apex/naked domain (example.com) not a FQDN (app.example.com) "), sg.Input('',size=(10,1), key = "domain_name")],

[sg.Text("BASTION HOSTS", font=title_font, pad=15)],
[sg.Text("SSH IP", tooltip="This IP will be included to the bastion security group and will be the only one capable of SSH to them. Introduce in the form 123.123.123.123. Without any mask"), sg.Input('',size=(10,1), key = "personal_ip")],

[sg.Text("CREDENTIALS", font=title_font, pad=15)],
[sg.Text("SSH Public Key", tooltip="Introduce the public ssh key of the key pair that must be created and located in the ~/.ssh folder. Just the .pub file (ex. myKey.pub)"), sg.Input('',size=(15,1), key = "ssh_key")],
[sg.Text("Db Secret ID", tooltip="This Secret must be created in AWS using AWS secrets manager service. This secret must be a key pair. The secret keys must be username and password. Secret values are up to you. Here just indicate the secret name (ex. db/key_pair)"), sg.Input('',size=(15,1), key = "secret_db_id", pad=(0,0,0,20))],


[sg.Text("BACKEND", font=title_font, pad=15)],
[sg.Text("Terraform workspace", tooltip="Terraform workspaces allow you to have the same .tf files with different states"),sg.Radio("Development", "workspace", default = True, key = "dev_workspace", enable_events=True), sg.Radio("Production", "workspace", default = False, key = "production_workspace", enable_events=True)],
[sg.Text("S3 Bucket", tooltip="HAS TO BE CREATED. here put the name of your S3 backend bucket"), sg.Input('',size=(15,1), key = "bucket_name")],
[sg.Text("Dynamo Lock Table", tooltip="HAS TO BE CREATED. Name of the DynamoDB table to achieve lock."), sg.Input('',size=(15,1), key = "dynamoDB_name")],


[sg.Button("Create", pad=(30,30,30,30), font=button_font)]]

layout = [
    [sg.Column(col1,element_justification='l', vertical_alignment="t"), sg.VSeperator(), sg.Column(col2, element_justification='l', vertical_alignment="t"), sg.VSeperator(), sg.Column(col3, element_justification='l', vertical_alignment="t")]
]

window = sg.Window('AWS HA Hosting Generator - by Martí Juncosa', layout)

while True:
    event, values = window.read()
    if event == sg.WIN_CLOSED:
        break

    elif event == 'max_instances' and values[event] < int(window['min_instances'].get()) :
        window['min_instances'].update(value = values[event])
    elif event == 'min_instances' and values[event] > int(window['max_instances'].get()) :
        window['max_instances'].update(value= values[event])

    elif event == 'memcached_elasticache':
        window['input_cluster'].update(disabled = True)
        window['input_elasti_encrypted'].update(disabled = True)
    elif event == 'redis_elasticache':
        window['input_cluster'].update(disabled = False)
        window['input_elasti_encrypted'].update(disabled = False)

    elif event == 'db_rds':
        window['db_storage'].update(disabled = False)
        window['text_db_storage'].update(text_color = "white")
        window['input_db_backups'].update(disabled = False)
    elif event == 'db_aurora':
        window['db_storage'].update(disabled = True)
        window['input_db_backups'].update(disabled = True)
        window['text_db_storage'].update(text_color = "#a9a9a9")

    elif event == "Create":
        

        main = """terraform {
        required_providers {
            aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
            }
        }

        backend "s3" {
            bucket = \"""" + values["bucket_name"] + """\"\n key    = \""""+ values["input_project_name"]+ """\"\n region = \"""" + values["input_region"] + """\"\n profile = \"""" + values["input_profile"]+ """\"\ndynamodb_table =  \"""" + values["dynamoDB_name"] + """\"\n
        }
        
        }

        provider "aws" {
        profile    = var.profile
        region     = var.region
        }

        provider "aws" {
        profile    = var.profile
        region     = "us-east-1"
        alias = "us-east-1"
        }"""

        value1 = "project_name = \"" + values["input_project_name"] + "\"\n"
        
        value2 = "region = \"" + values["input_region"]  + "\"\n"

        value3 = "profile = \""+ values["input_profile"]  + "\"\n"

        if values["db_rds"] == True:
            value19 = "db_type = \"rds\"\n"
        else:
            value19 = "db_type = \"aurora\"\n"

        value4 = "db_instance_type = \""+ values["input_db_instance"]  + "\"\n"

        value5 = "db_storage = "+ str(values["db_storage"])  + "\n"
        
        if values["input_db_backups"] == True:
            value6 = "db_backups = true\n"
        else:
            value6 = "db_backups = false\n"

        if values["input_db_encrypted"] == True:
            value24 = "db_encrypted = true\n"
        else:
            value24 = "db_encrypted = false\n"
        
        if values["memcached_elasticache"] == True:
            value7 = "elasticache_engine = \"memcached\"\n"
        else:
            value7 = "elasticache_engine = \"redis\"\n"
        
        value8 = "elasticache_instance_type = \""+ values["input_elasticache_instance"]  + "\"\n"

        if values["input_cluster"] == True:
            value9 = "cluster_mode = true\n"
        else:
            value9 = "cluster_mode = false\n"

        value10 = "number_read_replicas = "+ str(values["db_rr_number"])  + "\n"

        if values["input_elasti_encrypted"] == True:
            value25 = "elasticache_encrypted = true\n"
        else:
            value25 = "elasticache_encrypted = false\n"

        if values["input_spot"] == True:
            value11 = "is_spot = true\n"
        else:
            value11 = "is_spot = false\n"

        value12 = "spot_price = \""+ str(values["input_spot_price"])  + "\"\n"

        value13 = "instance_type = \""+ values["input_instance"]  + "\"\n"

        value14 = "autoscaling_max_size = "+ str(values["max_instances"])  + "\n"

        value15 = "autoscaling_min_size = "+ str(values["min_instances"])  + "\n"

        value16 = "policy_scale_up = "+ str(values["cpupolicyscaleup"])  + "\n"

        value17 = "policy_scale_down = "+ str(values["cpupolicyscaledown"])  + "\n"

        iterator = 0
        result = ""
        for i in values["cloudfornt_blacklist"]:
            iterator += 1
            if iterator == len(values["cloudfornt_blacklist"]):
                result += "\"" + i + "\""
            else: result += "\"" + i + "\","

        value18 = "georestrictions_cloudfornt = [" + result +"]\n"

        value20 = "domain = \"" + values["domain_name"] + "\"\n"

        value21 = "personal_ip = \"" + values["personal_ip"] + "\"\n"

        value22 = "ssh_public_key = \"" + values["ssh_key"] + "\"\n"

        value23 = "secretmanager_secret_id = \"" + values["secret_db_id"] + "\"\n"
        
        if values["dev_workspace"] == True:
            workspace = "dev.tfvars"
            value26 = "workspace = \"dev\"\n"
        else:
            workspace = "prd.tfvars"
            value26 = "workspace = \"prd\"\n"

        final = value1 + value2 + value3 + value19 + value4
        
        if values["db_rds"] == True:
            final += value5 + value6
        
        final += value24 + value7 + value8 
        
        if values["memcached_elasticache"] == False:
            final += value9 + value25
        
        final += value10 + value11 + value12 + value13 + value14 + value15 + value16 + value17
        
        if(iterator != 0):
            final += value18
        final += value20 + value21 + value22 + value23 + value26
        if (values["input_project_name"] != "" and values["input_profile"] != "" and values["input_db_instance"] != "" and values["input_elasticache_instance"] != "" and values["input_instance"] != "" and values["domain_name"] != "" and values["personal_ip"] != "" and values["ssh_key"] != "" and values["secret_db_id"] != "" and values["bucket_name"] != "" and values["dynamoDB_name"] != ""):
            if(values["input_spot"] == True and values["input_spot_price"] != "" or not values["input_spot"]):
                
                x = open( "main.tf", "w")
                x.write(main)
                x.close()

                f = open( workspace, "w")
                f.write(final)
                f.close()

                if values["dev_workspace"] == True:
                    os.system("project_init.bat " + values["input_project_name"] + " dev" )
                else:
                    os.system("project_init.bat " + values["input_project_name"] + " prd" )
            else: print("introduce the spot instance price!")
        else: print("Fill all the blank spaces!")
window.close()