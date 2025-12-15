# CI/CD для Django-застосунку на AWS

## 📌 Опис проєкту

Цей проєкт реалізує **повний CI/CD-процес для Django-застосунку** на AWS із використанням:

- **Terraform** — створення інфраструктури (S3 backend, VPC, ECR, EKS, Jenkins, Argo CD);
- **Docker + ECR** — зберігання контейнерних образів;
- **Helm** — деплоймент застосунку в Kubernetes;
- **Jenkins** — збірка образів і оновлення Helm-чартів;
- **Argo CD** — GitOps-синхронізація змін у кластері.

---

## 📂 Структура репозиторію

Project/
├── backend.tf # бекенд для state у S3 + DynamoDB
├── main.tf # підключення модулів (S3, VPC, ECR, EKS, Jenkins, Argo CD)
├── outputs.tf # виводи (ECR repo, EKS endpoint, Jenkins URL, Argo CD URL)
├── Jenkinsfile # pipeline (build → push → update Helm → push)
│
├── modules/
│ ├── s3-backend/ # модуль для S3 та DynamoDB
│ ├── vpc/ # модуль для VPC
│ ├── ecr/ # модуль для ECR
│ ├── eks/ # модуль для EKS
│ ├── jenkins/ # модуль для Helm-установки Jenkins
│ └── argo_cd/ # модуль для Helm-установки Argo CD + Application
│
└── charts/
└── django-app/ # Helm-чарт для Django (deployment, service, configmap, hpa)

---

## ⚙️ Компоненти

### 1. Terraform

- **S3 + DynamoDB** — зберігання state із блокуванням;
- **VPC** — публічні та приватні підмережі, NAT gateway, маршрутизація;
- **ECR** — приватний реєстр для Docker-образів;
- **EKS** — кластер Kubernetes із node group;
- **Jenkins** — деплой через Helm;
- **Argo CD** — деплой через Helm.

### 2. Jenkins

- Збирає Docker-образ із `Dockerfile`;
- Пушить образ у **Amazon ECR**;
- Оновлює тег у `charts/django-app/values.yaml` у Git;
- Пушить зміни в гілку `main`.

### 3. Argo CD

- Слідкує за репозиторієм із Helm-чартом;
- При зміні `values.yaml` синхронізує застосунок у кластері;
- Забезпечує GitOps-підхід.

---

## 🚀 Pipeline (Jenkinsfile)

1. **Checkout** → код Django
2. **Build & Push** → збірка образу через Kaniko, пуш у ECR
3. **Bump Helm values** → оновлення `image.tag` у `values.yaml`
4. **Git Push** → коміт і пуш у репозиторій із Helm-чартом
5. **Argo CD Sync** → автоматичне оновлення застосунку в кластері

---

## 🔑 Попередні вимоги

- AWS CLI + IAM користувач із правами на EKS/ECR/S3/DynamoDB;
- `kubectl` і `helm` локально;
- Terraform >= 1.5.0;
- Два GitHub-репозиторії:
  - цей (інфраструктура + Jenkinsfile),
  - окремий для Helm-чарту застосунку (`charts/django-app`).

---

## 📖 Команди

### Terraform

```bash
terraform init
terraform plan
terraform apply
```
