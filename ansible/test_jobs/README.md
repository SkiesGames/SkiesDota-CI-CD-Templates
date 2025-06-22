# Test Jobs

This directory contains GitLab CI job definitions for testing Ansible roles using Molecule.

## Available Test Jobs

### test_mongodb
Tests the MongoDB role with comprehensive verification.

**Features:**
- Extends `.molecule_test` template
- Tests replica set initialization
- Verifies index creation
- Validates TTL index configuration
- Comprehensive integration testing

**Test Coverage:**
- MongoDB container deployment
- Replica set configuration
- Index creation and validation
- TTL index functionality
- Role idempotency

**Variables:**
- `ROLE_NAME`: mongodb
- Uses `$CI_REGISTRY_IMAGE/ansible-test:latest` image

### test_deploy_integration
Tests the deploy role integration and functionality.

**Features:**
- Extends `.molecule_test` template
- Tests file synchronization
- Verifies environment file creation
- Validates Docker Compose integration
- End-to-end deployment testing

**Test Coverage:**
- File synchronization from CI/CD
- Environment file management
- Docker Compose service management
- Permission and security validation
- Integration between sub-roles

**Variables:**
- `ROLE_NAME`: deploy
- Uses `$CI_REGISTRY_IMAGE/ansible-test:latest` image

## Test Job Template (.molecule_test)

Shared configuration for all Molecule test jobs:

**Features:**
- **Stage**: test
- **Image**: `$CI_REGISTRY_IMAGE/ansible-test:latest`
- **Services**: Docker-in-Docker for test environments
- **Before Script**: Role directory navigation
- **Script**: Molecule test execution
- **After Script**: Cleanup and destruction

**Execution Rules:**
- **Automatic**: When role files change
- **Manual**: Always available for manual testing

## Test Environment

### Docker Configuration
- Uses Docker-in-Docker service
- Optimized for Molecule testing
- Non-root user for security
- Shared Docker socket access

### Molecule Configuration
- Template-based configuration
- Customizable prepare/verify playbooks
- Environment variable support
- Standardized test structure

## Test Execution Flow

1. **Environment Setup**: Docker container preparation
2. **Role Navigation**: Change to role directory
3. **Molecule Test**: Execute full test suite
4. **Cleanup**: Destroy test environments
5. **Result Reporting**: Display test results

## Test Coverage Standards

All role tests must verify:

### Basic Functionality
- Role execution without errors
- Idempotent operation
- Proper file creation/modification
- Correct permissions and ownership

### Integration Testing
- Role dependencies work correctly
- Multi-role interactions function properly
- End-to-end workflows succeed
- Error handling and recovery

### Security Validation
- Secure file permissions
- Proper credential handling
- No sensitive data exposure
- Access control verification

## Adding New Test Jobs

To add a test job for a new role:

1. **Create Job Definition**:
```yaml
test_role_name:
  extends: .molecule_test
  variables:
    ROLE_NAME: role_name
```

2. **Ensure Role Has Tests**:
   - `molecule/default/prepare.yml`
   - `molecule/default/verify.yml`
   - `molecule/default/molecule.yml`

3. **Update Documentation**:
   - Add to this README
   - Document test coverage
   - List required variables

## Test Dependencies

All test jobs require:
- Built test image (`ansible-test:latest`)
- Docker-in-Docker service
- Role with Molecule configuration
- Proper GitLab CI/CD variables

## Best Practices

- **Comprehensive Coverage**: Test all role functionality
- **Idempotency**: Verify role can run multiple times
- **Error Handling**: Test failure scenarios
- **Security**: Validate security configurations
- **Performance**: Ensure tests complete in reasonable time

## Troubleshooting

### Common Issues
- **Docker Permissions**: Ensure proper Docker socket access
- **Role Dependencies**: Verify all required roles are available
- **Variable Configuration**: Check all required variables are set
- **Network Access**: Ensure test containers can communicate

### Debug Mode
Enable debug output by setting `MOLECULE_DEBUG=true` in GitLab CI variables. 