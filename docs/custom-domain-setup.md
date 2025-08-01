# Setting Up Custom Domains with Google Cloud Run

This guide explains how to map your custom domain (myn8n.com and its subdomains) to your Google Cloud Run service.

## Prerequisites

- A domain name (e.g., myn8n.com) registered with a domain registrar
- Access to your domain's DNS settings
- A deployed Cloud Run service
- Google Cloud SDK installed and configured

## Steps

### 1. Verify Domain Ownership

Before you can map a custom domain to your Cloud Run service, you need to verify that you own the domain.

```bash
# Add your domain to Google Cloud
gcloud domains verify myn8n.com
```

Follow the instructions to add a TXT record to your domain's DNS settings.

### 2. Map Custom Domains to Cloud Run Service

Once your domain is verified, you can map it to your Cloud Run service. You'll need to map each subdomain separately.

```bash
# Map the main domain and subdomains to your Cloud Run service
gcloud beta run domain-mappings create --service=dev-stack --domain=llm.myn8n.com --region=us-central1
gcloud beta run domain-mappings create --service=dev-stack --domain=chat.myn8n.com --region=us-central1
gcloud beta run domain-mappings create --service=dev-stack --domain=n8n.myn8n.com --region=us-central1
gcloud beta run domain-mappings create --service=dev-stack --domain=s3-console.myn8n.com --region=us-central1
gcloud beta run domain-mappings create --service=dev-stack --domain=s3.myn8n.com --region=us-central1
gcloud beta run domain-mappings create --service=dev-stack --domain=db.myn8n.com --region=us-central1
gcloud beta run domain-mappings create --service=dev-stack --domain=monitor.myn8n.com --region=us-central1
gcloud beta run domain-mappings create --service=dev-stack --domain=metrics.myn8n.com --region=us-central1
```

### 3. Configure DNS Records

After creating the domain mappings, Google Cloud will provide you with the necessary DNS records to add to your domain's DNS settings.

For each subdomain, you'll need to add a CNAME record pointing to the provided Google-managed domain. For example:

```
llm.myn8n.com CNAME ghs.googlehosted.com.
chat.myn8n.com CNAME ghs.googlehosted.com.
# ... and so on for each subdomain
```

Alternatively, you can add an A record for the apex domain (myn8n.com) pointing to the IP addresses provided by Google Cloud.

### 4. Set Up SSL Certificates

Google Cloud Run automatically provisions and manages SSL certificates for your custom domains. Once the DNS records have propagated, SSL certificates will be issued automatically.

You can check the status of your domain mappings with:

```bash
gcloud beta run domain-mappings list --region=us-central1
```

### 5. Test Your Custom Domains

After the DNS records have propagated (which can take up to 48 hours, but usually happens within a few hours), you can test your custom domains by visiting them in a web browser.

```
https://llm.myn8n.com
https://chat.myn8n.com
# ... and so on for each subdomain
```

## Troubleshooting

### DNS Propagation

If your custom domains are not working, it might be because the DNS records have not yet propagated. You can check the propagation status using online tools like [dnschecker.org](https://dnschecker.org/).

### SSL Certificate Issues

If you're seeing SSL certificate errors, it might be because the certificates have not yet been provisioned. This can take some time after the DNS records have propagated. You can check the status of your SSL certificates with:

```bash
gcloud beta run domain-mappings describe --domain=llm.myn8n.com --region=us-central1
```

### Service Not Accessible

If your service is not accessible through the custom domains, check that:

1. The Cloud Run service is running and accessible through its default URL
2. The domain mappings have been created successfully
3. The DNS records have been configured correctly
4. The service is configured to allow unauthenticated access (if applicable)

## Additional Resources

- [Google Cloud Run Documentation: Mapping Custom Domains](https://cloud.google.com/run/docs/mapping-custom-domains)
- [Google Cloud Run Documentation: Managing SSL Certificates](https://cloud.google.com/run/docs/securing/custom-domains#managing_ssl_certificates)