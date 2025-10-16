#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LAB_DIR="$HOME/containerlab-labs/srl-xrv9k-lab"
TF_DIR="$LAB_DIR/terraform"
CLAB_FILE="$LAB_DIR/srl-xrv9k.clab.yml"

function print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

function deploy() {
    print_header "Deploying Multi-Vendor Lab (SR Linux + XRv9k)"
    echo -e "${YELLOW}Note: XRv9k takes ~2 minutes to boot${NC}"
    cd "$TF_DIR"
    terraform apply -auto-approve
    echo -e "${GREEN}✓ Lab deployed successfully${NC}"
}

function destroy() {
    print_header "Destroying Multi-Vendor Lab"
    cd "$TF_DIR"
    terraform destroy -auto-approve
    echo -e "${RED}✓ Lab destroyed successfully${NC}"
}

function status() {
    print_header "Multi-Vendor Lab Status"
    sudo containerlab inspect -t "$CLAB_FILE"
}

function plan() {
    print_header "Terraform Plan for Multi-Vendor Lab"
    cd "$TF_DIR"
    terraform plan
}

function connect_srl() {
    IP=$(sudo containerlab inspect -t "$CLAB_FILE" | grep -w srl | awk '{print $6}')
    echo -e "${GREEN}Connecting to SR Linux at $IP${NC}"
    echo -e "${YELLOW}Credentials: admin / NokiaSrl1!${NC}"
    ssh admin@$IP
}

function connect_xrv9k() {
    IP=$(sudo containerlab inspect -t "$CLAB_FILE" | grep xrv9k | awk '{print $6}')
    echo -e "${GREEN}Connecting to XRv9k at $IP${NC}"
    echo -e "${YELLOW}Credentials: clab / clab@123${NC}"
    ssh clab@$IP
}

function check_xrv9k_logs() {
    echo -e "${BLUE}XRv9k Boot Logs:${NC}"
    docker logs clab-srl-xrv9k-xrv9k | tail -30
}

function show_menu() {
    echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Multi-Vendor Lab Manager            ║${NC}"
    echo -e "${GREEN}║   (Nokia SR Linux + Cisco XRv9k)      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
    echo "1) Deploy Lab"
    echo "2) Destroy Lab"
    echo "3) Show Status"
    echo "4) Show Terraform Plan"
    echo "5) Connect to SR Linux (admin/NokiaSrl1!)"
    echo "6) Connect to XRv9k (clab/clab@123)"
    echo "7) Check XRv9k Boot Logs"
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
    connect-srl)
        connect_srl
        ;;
    connect-xrv9k)
        connect_xrv9k
        ;;
    logs)
        check_xrv9k_logs
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
                5) connect_srl ;;
                6) connect_xrv9k ;;
                7) check_xrv9k_logs ;;
                0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
                *) echo -e "${RED}Invalid option${NC}" ;;
            esac
        done
        ;;
esac
