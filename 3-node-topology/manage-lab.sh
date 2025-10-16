#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LAB_DIR="$HOME/containerlab-labs/3-node-topology"
TF_DIR="$LAB_DIR/terraform"
CLAB_FILE="$LAB_DIR/clos01.clab.yml"

function print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

function deploy() {
    print_header "Deploying 3-Node Clos Fabric Lab"
    cd "$TF_DIR"
    terraform apply -auto-approve
    echo -e "${GREEN}✓ Lab deployed successfully${NC}"
}

function destroy() {
    print_header "Destroying 3-Node Clos Fabric Lab"
    cd "$TF_DIR"
    terraform destroy -auto-approve
    echo -e "${RED}✓ Lab destroyed successfully${NC}"
}

function status() {
    print_header "3-Node Clos Fabric Lab Status"
    sudo containerlab inspect -t "$CLAB_FILE"
}

function plan() {
    print_header "Terraform Plan for 3-Node Clos Fabric"
    cd "$TF_DIR"
    terraform plan
}

function connect_leaf1() {
    IP=$(sudo containerlab inspect -t "$CLAB_FILE" | grep leaf1 | awk '{print $6}')
    echo -e "${GREEN}Connecting to leaf1 at $IP${NC}"
    ssh admin@$IP
}

function connect_leaf2() {
    IP=$(sudo containerlab inspect -t "$CLAB_FILE" | grep leaf2 | awk '{print $6}')
    echo -e "${GREEN}Connecting to leaf2 at $IP${NC}"
    ssh admin@$IP
}

function connect_spine1() {
    IP=$(sudo containerlab inspect -t "$CLAB_FILE" | grep spine1 | awk '{print $6}')
    echo -e "${GREEN}Connecting to spine1 at $IP${NC}"
    ssh admin@$IP
}

function connect_client1() {
    echo -e "${GREEN}Connecting to client1${NC}"
    docker exec -it clab-clos01-client1 sh
}

function connect_client2() {
    echo -e "${GREEN}Connecting to client2${NC}"
    docker exec -it clab-clos01-client2 sh
}

function show_menu() {
    echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   3-Node Clos Fabric Lab Manager      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
    echo "1) Deploy Lab"
    echo "2) Destroy Lab"
    echo "3) Show Status"
    echo "4) Show Terraform Plan"
    echo "5) Connect to leaf1"
    echo "6) Connect to leaf2"
    echo "7) Connect to spine1"
    echo "8) Connect to client1"
    echo "9) Connect to client2"
    echo "0) Exit"
    echo ""
}

case "$1" in
    deploy)
        deploy
        ;;
    destroy)
        destroy
        ;;
    status)
        status
        ;;
    plan)
        plan
        ;;
    connect-leaf1)
        connect_leaf1
        ;;
    connect-leaf2)
        connect_leaf2
        ;;
    connect-spine1)
        connect_spine1
        ;;
    connect-client1)
        connect_client1
        ;;
    connect-client2)
        connect_client2
        ;;
    *)
        while true; do
            show_menu
            read -p "Select option: " choice
            case $choice in
                1) deploy ;;
                2) destroy ;;
                3) status ;;
                4) plan ;;
                5) connect_leaf1 ;;
                6) connect_leaf2 ;;
                7) connect_spine1 ;;
                8) connect_client1 ;;
                9) connect_client2 ;;
                0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
                *) echo -e "${RED}Invalid option${NC}" ;;
            esac
        done
        ;;
esac
