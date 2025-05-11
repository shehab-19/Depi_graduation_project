# 🚀 QR Code Generator and Scanner Application

> A modern, containerized ASP.NET Core application for generating and scanning QR codes. Built with cloud-native principles and deployed using DevOps best practices, featuring infrastructure automation with Terraform, Kubernetes orchestration with Kind, and Helm-based deployment.

## 🌐 Tech Stack

### Application Layer
- **Frontend**: 
  - HTML, CSS
  - Bootstrap for responsive design
  - Razor views (.cshtml) for server-side rendering
- **Backend**: ASP.NET Core MVC 8.0
- **Database**: Microsoft SQL Server
- **QR Code Libraries**: QRCoder, ZXing.Net
- **Image Processing**: SkiaSharp

### DevOps & Infrastructure
- **Containerization**: Docker with multi-stage builds
- **Container Orchestration**: Kubernetes (Kind)
- **Package Management**: Helm
- **Infrastructure as Code**: Terraform
- **Load Balancing**: NGINX Ingress Controller
- **Cloud Provider**: AWS
  - RDS for SQL Server
  - EC2 for Kubernetes nodes
  - VPC networking

## 🔑 Features
- Generate QR codes from text input
- Scan and decode QR codes
- Store QR code history in database
- View generation history
- Responsive web interface
- Cloud-native deployment ready

## 🚀 Deployment Methods

### 1. Local Development with Docker Compose

```bash
# Navigate to the QRCodeApp directory
cd QRCodeApp

# Create and configure your .env file based on the template
cp .env.example .env
# Edit the .env file with your desired configuration

# Start the application and database
docker compose up --build
```

The application will be available at http://localhost:${EXTERNAL_APP_PORT}

### 2. Kubernetes Deployment with Kind

#### Prerequisites
- Docker
- kubectl
- Kind
- Helm

#### Setup and Deploy

1. Create Kind cluster:
```bash
chmod +x kind_cluster_setup.sh
./kind_cluster_setup.sh
```

2. Deploy using Helm:
```bash
helm install qrcode ./QRCode_APP_Chart \
  --set-string Secret.DB_PASSWORD="YOUR_PASSWORD" \
  --set-string Secret.DB_HOST="YOUR_DB_HOST" \
  --set-string Secret.DB_NAME="QRCodeDB" \
  --set-string Secret.DB_USER="YOUR_DB_USER"
```

### 3. Production Deployment to AWS

1. Configure AWS credentials
2. Initialize Terraform:
```bash
cd infra
terraform init
terraform apply
```

This will:
- Create VPC networking
- Deploy RDS SQL Server instance
- Set up EC2 instance for Kubernetes
- Configure security groups and IAM roles

## 🛠️ Environment Variables

The application uses the following environment variables which should be defined in a `.env` file based on the provided `.env.example` template:

- `DB_HOST`: Database hostname
- `DB_NAME`: Database name
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password
- `APP_PORT`: Application internal port
- `EXTERNAL_APP_PORT`: Application external port
- `DB_PORT`: Database internal port
- `EXTERNAL_DB_PORT`: Database external port
- `DOCKER_REGISTRY`: (Optional) Docker registry URL

## 📦 Dependencies

### Application
- Microsoft.EntityFrameworkCore.SqlServer
- QRCoder
- SkiaSharp
- ZXing.Net

### Infrastructure
- Docker
- Kubernetes
- Helm
- Terraform
- AWS CLI

## 🔐 Security Notes

- Database credentials are managed through environment variables
- SSL/TLS encryption for database connections
- Kubernetes secrets for sensitive data
- AWS security groups for network isolation

## 📈 Monitoring and Scaling

- Application supports horizontal scaling through Kubernetes
- Health checks configured in Kubernetes deployments
- Static files served through NGINX
- Database connection resilience with automatic reconnection


## 🎯 Conclusion

This QR Code Generator and Scanner application demonstrates a complete end-to-end solution combining modern web technologies with cloud-native deployment practices. Key highlights include:

- **Modern Web Stack**: Utilizes Bootstrap for a responsive, user-friendly interface while leveraging ASP.NET Core's powerful Razor view engine
- **Scalable Architecture**: Built with cloud-native principles, supporting containerization and orchestration
- **DevOps Best Practices**: Implements Infrastructure as Code, automated deployments, and proper secret management
- **Production Ready**: Includes comprehensive documentation, deployment options, and security considerations

The project serves as an excellent example of how to build and deploy a full-stack web application using modern DevOps practices, making it suitable for both learning purposes and production use.