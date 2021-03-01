This document contains information and guidelines about contributing to this project. Please read it before you start participating.

## Asking Questions

We don't use GitHub as a support forum. If you have issues with the APIs or have a question about the Push Notification services, refer https://cloud.ibm.com/docs/mobilepush?topic=mobilepush-mp-report-problem

## Reporting Issues

See the [issue template](issueTemplate.md).

## Coding Style

-   [Swift coding style reference 1](https://swift.org/documentation/api-design-guidelines/)
-   [Swift coding style reference 2](https://google.github.io/swift/)
-   [Swift and Xcode reference](https://developer.apple.com/swift/resources/)

## Pull Requests

If you want to contribute to the repository, here's a quick guide:
1.  Fork the repository.
2.  Develop and test your code changes.
-   Please respect the original code
-   Create minimal diffs - disable on save actions like reformat source code or organize imports. If you feel the source code should be reformatted create a separate PR for this change.
-   Check for unnecessary whitespace with `git diff --check` before committing.

3.  Verify . To run tests in Xcode, select the service's scheme and press `cmd-u`. Instructions on running the Swift tests on Linux while on a Mac can be found [here](https://github.com/watson-developer-cloud/swift-sdk/wiki/Running-Swift-Linux-Tests-on-Mac).
4.  Push to your fork and submit a pull request to the **develop** branch.

## Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
   have the right to submit it under the open source license
   indicated in the file; or

(b) The contribution is based upon previous work that, to the best
   of my knowledge, is covered under an appropriate open source
   license and I have the right under that license to submit that
   work with modifications, whether created in whole or in part
   by me, under the same open source license (unless I am
   permitted to submit under a different license), as indicated
   in the file; or

(c) The contribution was provided directly to me by some other
   person who certified (a), (b) or (c) and I have not modified
   it.

(d) I understand and agree that this project and the contribution
   are public and that a record of the contribution (including all
   personal information I submit with it, including my sign-off) is
   maintained indefinitely and may be redistributed consistent with
   this project or the open source license(s) involved.

### Additional Resources
-   [General GitHub documentation](https://help.github.com/)
-   [GitHub pull request documentation](https://help.github.com/send-pull-requests/)

---