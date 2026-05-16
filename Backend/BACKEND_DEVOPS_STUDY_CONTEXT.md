# Backend and DevOps Study Context

## Purpose

This document summarizes:

- what has already been studied or practiced in this FinTracker project
- what is still left to study in backend development
- what is left to study in DevOps
- a practical roadmap including AWS deployment and GitHub Actions

This can be used as:

- a personal study tracker
- a roadmap for what to build next
- context for an AI mentor or planner

## Current Project Context

The current project is a Spring Boot backend called `FinTracker`.

It currently includes:

- Spring Boot application setup
- PostgreSQL database integration
- JPA entities and repositories
- DTO-based request and response handling
- service layer
- controller layer
- JWT authentication
- Spring Security route protection
- BCrypt password hashing
- CRUD APIs for users, assets, and transactions
- config-driven JWT secret and expiration
- local profile-based configuration
- `/me` endpoint using authenticated user identity
- asset ownership enforcement based on authenticated user
- transaction ownership enforcement based on authenticated user
- DTO validation for asset and transaction creation
- global exception handling for validation and common API errors

This means a large part of beginner-to-intermediate backend learning has already been covered.

## What Has Already Been Studied

Based on this project, the following backend topics have already been practiced.

## 1. Java and Spring Boot Basics

- creating a Spring Boot project
- understanding project structure
- using `@RestController`
- using `@Service`
- using `@Repository`
- using dependency injection through constructors
- using configuration files like `application.properties`

## 2. REST API Development

- creating REST endpoints
- using HTTP methods like `GET`, `POST`, `PUT`, and `DELETE`
- handling path variables
- handling request bodies
- returning `ResponseEntity`
- designing DTOs for request and response separation

## 3. Database and Persistence

- using PostgreSQL with Spring Boot
- configuring datasource properties
- using Spring Data JPA
- creating entities
- defining relationships:
  - one user to many assets
  - one asset to many transactions
- using repositories for CRUD operations
- saving and fetching relational data

## 4. Authentication and Security

- basic Spring Security setup
- route protection using security config
- JWT-based authentication
- generating JWT tokens
- validating JWT tokens
- extracting user identity from JWT
- using `Authorization: Bearer <token>`
- password hashing with BCrypt
- login and register flow
- understanding how `SecurityContextHolder` is populated by a JWT filter
- reading authenticated user identity from Spring Security context
- building `/me` endpoint from authenticated user identity
- using authentication for ownership-aware backend logic

## 5. Validation and DTO Design

- request DTO validation using annotations like:
  - `@NotBlank`
  - `@Email`
  - `@Size`
- separating entity models from API contracts
- using `@NotNull` and `@Positive` for numeric and required request fields
- using `@Valid` in controllers to trigger request validation

## 6. Backend Architecture Basics

- layered architecture
- separating controller, service, repository, DTO, entity, and config classes
- avoiding direct entity exposure in API responses
- service-layer DTO mapping such as `User -> UserResponseDTO`
- ownership-aware repository query methods such as `findByIdAndUserEmail(...)`
- ownership-aware nested repository query methods such as `findByIdAndAssetUserEmail(...)`

## 7. Backend-to-Frontend Integration Thinking

- understanding how frontend sends API body data
- understanding JSON request and response shapes
- understanding JWT storage and protected API calls
- documenting backend for frontend generation

## 8. Configuration and Environment Practice Already Done

- moved datasource config out of hardcoded values in main config
- moved JWT secret and expiration out of Java source code
- used Spring property placeholders with environment-variable style config
- added `application-local.properties` for local development
- practiced profile-based local running

## 9. Authorization and Ownership Practice Already Done

- added `GET /users/me`
- derived current user from JWT-backed Spring Security context
- changed asset creation to use authenticated user instead of client-provided `userId`
- restricted asset listing to the authenticated user
- restricted asset fetch-by-id to the authenticated user
- restricted asset deletion to the authenticated user
- restricted transaction creation to assets owned by the authenticated user
- restricted transaction listing to the authenticated user
- restricted transaction fetch-by-id to the authenticated user
- restricted transaction deletion to the authenticated user
- restricted user read/update/delete flows to the authenticated user

## 10. Validation and Exception Handling Practice Already Done

- added validation annotations to asset and transaction request DTOs
- used `@Valid` on create endpoints
- learned how `MethodArgumentNotValidException` is triggered
- built structured API error response DTO
- added global exception handling with `@RestControllerAdvice`
- handled validation errors centrally using field-to-message maps
- handled `IllegalArgumentException` and generic fallback exceptions centrally
- studied the tradeoff between `Optional` / `boolean` and custom exceptions
- created and used a custom `ResourceNotFoundException`
- mapped custom not-found exceptions to `404 Not Found`
- refactored selected service methods from `Optional` / `boolean` style to exception-based flow
- simplified controllers by delegating not-found response handling to global exception advice

## What Is Still Left to Study in Backend

Even if the basic backend is mostly done, there are still several important backend topics left before the project feels complete or production-ready.

## 0. Learning Mode for This Project

This project should be used in a teaching-first way.

- the goal is not vibe coding or just generating an app quickly
- the goal is to understand backend engineering deeply by writing code step by step
- when working with an AI mentor, prefer:
  - explanation first
  - small implementation tasks
  - guided coding
  - code review and correction
  - exercises that require the learner to write parts of the code
- use the project as a study lab for real engineering topics, not just feature delivery

## 1. Production-Ready Security

- move JWT secret out of source code into environment variables or config
- move token expiration config out of source code
- add proper CORS configuration
- add role-based authorization if needed
- learn about token refresh flows
- learn about server-side logout or token blacklisting
- protect against common API security issues

## 2. Better API Design

- standardized API response structure
- keep improving standardized error response structure
- keep improving global exception handling using `@ControllerAdvice`
- pagination for list APIs
- filtering and sorting
- search endpoints
- versioning APIs if needed

## 3. Better Domain Design

- continue deriving current user from JWT instead of taking `userId` from client
- extend `/me` and ownership patterns consistently across all domains
- improve ownership and authorization checks
- add update endpoints where missing

## 4. Validation and Data Integrity

- keep refining validation for asset and transaction DTOs
- add database constraints like unique email
- handle duplicate email registration
- add better null handling and input checking
- enforce valid enum-style values for fields like `BUY`, `SELL`, `CRYPTO`, `STOCK`

## 5. Testing

- unit tests for services
- controller tests
- repository tests
- authentication tests
- integration tests
- test containers or containerized DB testing
- coverage mindset

## 6. Configuration and Environments

- separate config for local, dev, staging, and production
- use Spring profiles
- store secrets securely
- environment-based database config
- environment-based logging config

## 7. Observability and Operations

- structured logging
- log levels
- health checks
- metrics
- monitoring
- application tracing basics

## 8. Documentation

- Swagger / OpenAPI
- setup documentation
- deployment documentation
- API usage examples

## 9. Scaling, Caching, and Architecture

These topics are important next-stage backend learning areas and should be studied with this project.

### Scaling

- vertical scaling vs horizontal scaling
- stateless app design and why JWT helps horizontal scaling
- database bottlenecks
- connection pooling
- pagination for large datasets
- read-heavy vs write-heavy systems
- load balancer basics
- separating application tier and database tier
- background jobs and asynchronous processing basics

### Caching

- what caching solves
- cache-aside pattern
- in-memory cache vs distributed cache
- when to use Redis
- caching hot read endpoints
- cache invalidation basics
- TTL and stale data tradeoffs
- why not every endpoint should be cached
- authentication and user-specific caching concerns

### Architecture

- monolith vs microservices
- clean architecture vs layered architecture
- service boundaries
- DTO mapping patterns
- transaction boundaries
- domain modeling improvements
- event-driven thinking basics
- idempotency basics
- designing for maintainability, not only correctness

## What Is Still Left to Study in DevOps

DevOps is much broader than just deployment. A strong learning plan should include automation, infrastructure, deployment, monitoring, and reliability.

## 1. Git and Collaboration

- proper branching workflows
- pull request workflow
- semantic commit habits
- release/version tagging
- handling merge conflicts
- repo hygiene and README quality

## 2. CI/CD Fundamentals

- what CI means
- what CD means
- pipeline stages
- build automation
- test automation
- deployment automation

## 3. GitHub Actions

Important things to learn:

- workflow files in `.github/workflows`
- triggers:
  - `push`
  - `pull_request`
  - manual dispatch
- jobs and steps
- using actions from marketplace
- caching dependencies
- running Maven builds
- running tests
- setting environment variables
- using GitHub secrets
- deployment jobs

For this project, good GitHub Actions practice would include:

- build the Spring Boot app
- run tests
- package the app
- optionally build a Docker image
- deploy automatically after merge to main

## 4. Docker

Must-study topics:

- what Docker is
- images and containers
- writing a `Dockerfile`
- Dockerizing Spring Boot apps
- exposing ports
- environment variable injection
- Docker volumes
- Docker networking
- multi-container setup with app + PostgreSQL

For this project, a good next step is:

- Dockerize the backend
- create `docker-compose.yml` for backend + database

## 5. Deployment Basics

- difference between local, staging, and production
- build artifacts: jar, container image
- environment variables in deployment
- port mapping
- domain and DNS basics
- reverse proxy basics

## 6. AWS Fundamentals

Important AWS topics to study:

- IAM
- EC2
- S3
- RDS
- VPC basics
- Security Groups
- CloudWatch
- Elastic Beanstalk
- ECS basics
- ECR
- Route 53 basics
- Load Balancer basics
- Secrets management basics

## 7. AWS Deployment Options for This Project

There are multiple reasonable ways to deploy this project on AWS.

### Option 1: EC2 + PostgreSQL

Study:

- launching an EC2 instance
- connecting through SSH
- installing Java
- running Spring Boot jar
- configuring environment variables
- setting up PostgreSQL on the same server or separately
- opening ports using security groups
- using Nginx reverse proxy

This is good for learning fundamentals.

### Option 2: EC2 + Docker + PostgreSQL

Study:

- installing Docker on EC2
- running the app in a container
- using Docker Compose
- app container + database container

This is a good practical next step after learning plain EC2 deployment.

### Option 3: AWS RDS + EC2 App Server

Study:

- app on EC2
- database on RDS PostgreSQL
- secure DB connection
- network/security group configuration

This is closer to real production architecture.

### Option 4: Elastic Beanstalk

Study:

- easier managed deployment for Spring Boot
- environment config
- logs and monitoring

This is easier than manually managing everything.

### Option 5: ECS / Fargate

Study:

- container registry with ECR
- task definitions
- services
- networking

This is more advanced and useful later.

## 8. Monitoring and Reliability

- application logs
- CloudWatch logs
- CPU and memory monitoring
- uptime checks
- alerting basics
- backup strategy for database
- rollback thinking

## What You Should Study Next in Order

If your goal is to become strong in backend + DevOps, a practical order would be:

## Phase 1: Finish This Backend Properly

- keep improving JWT secret and expiry handling across environments
- add CORS config
- build on `/me` endpoint
- keep deriving current user from JWT
- extend exception handling with custom exceptions where needed
- add unique email check
- add OpenAPI/Swagger docs
- add tests

## Phase 2: Learn Architecture, Scaling, and Caching Through This Backend

- understand current layered architecture
- refactor endpoints to use authenticated user ownership
- add pagination to list endpoints
- study where caching would and would not help
- add a simple cache for safe read endpoints
- study stateless scaling with JWT
- learn database and application bottlenecks

## Phase 3: Dockerize the Project

- write a `Dockerfile`
- create `docker-compose.yml`
- run app + PostgreSQL together
- move config to env variables

## Phase 4: Add CI with GitHub Actions

- build on push
- run tests on push and PR
- fail pipeline if tests fail
- optionally build Docker image

## Phase 5: Deploy to AWS

Recommended learning order:

1. Deploy Spring Boot jar on EC2
2. Deploy using Docker on EC2
3. Move PostgreSQL to RDS
4. Add domain/reverse proxy if needed
5. Add GitHub Actions deployment automation

## Phase 6: Improve Production Readiness

- monitoring
- logs
- backups
- rollback strategy
- secrets handling
- staging vs production

## Suggested GitHub Actions Workflow for This Project

A useful first pipeline would do:

1. checkout code
2. set up Java
3. cache Maven dependencies
4. run Maven build
5. run tests
6. package the app

Later you can extend it to:

- build Docker image
- push image to Docker Hub or ECR
- deploy to EC2 automatically

## Suggested Deliverables to Build Next

If you want to turn this project into a full learning portfolio, these are strong next deliverables:

- production-ready backend improvements
- Docker setup
- GitHub Actions CI pipeline
- AWS deployment guide
- deployed live backend
- frontend client
- full-stack deployed app

## Study Checklist

Use this as a checklist.

### Backend completed or mostly studied

- Spring Boot basics
- controller/service/repository architecture
- PostgreSQL integration
- JPA entities and relationships
- DTOs
- CRUD APIs
- authentication
- JWT
- password hashing
- request validation
- config externalization basics
- Spring Security context basics
- authenticated `/me` endpoint
- asset ownership enforcement
- transaction ownership enforcement
- request validation with `@Valid`
- centralized exception handling basics
- custom exception basics

### Backend still to study

- richer exception-mapping design beyond basic not-found handling
- better validation
- authorization polishing and endpoint design cleanup
- refresh tokens
- scaling basics
- caching basics
- architecture and design tradeoffs
- Swagger/OpenAPI
- testing
- profiles and environments
- logging and monitoring
- production-grade config

### DevOps still to study

- Docker
- Docker Compose
- GitHub Actions
- CI/CD pipelines
- EC2 deployment
- RDS setup
- Nginx basics
- environment variables and secrets
- CloudWatch basics
- backups and rollback

### AWS topics to study

- IAM
- EC2
- RDS
- S3 basics
- ECR
- ECS basics
- Elastic Beanstalk
- security groups
- CloudWatch
- Route 53 basics

## Final Assessment

You have already studied a strong amount of backend through this project. The remaining gap is not basic CRUD anymore. The main things left are:

- production-quality backend improvements
- testing
- containerization
- CI/CD
- cloud deployment
- monitoring and operational thinking

That means you are at a very good point to transition from "learning backend syntax and CRUD" into "learning real backend engineering and DevOps."

## Suggested Next Practical Goal

A very strong next goal would be:

`Take this FinTracker backend from local CRUD project to deployed production-style backend with Docker, GitHub Actions, and AWS.`

That single path will teach you:

- backend hardening
- environment management
- containerization
- CI/CD
- deployment
- cloud basics
- real project workflow
