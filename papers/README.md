# Local paper library

PDFs in this directory are intentionally ignored by Git. This manifest records their sources so the local library can be reconstructed without redistributing paper files.

| Local file | Source | Version | SHA-256 |
|---|---|---|---|
| `deepseek-r1-arxiv-2501.12948v2.pdf` | [arXiv:2501.12948](https://arxiv.org/abs/2501.12948) | v2, 4 January 2026; related article in *Nature* 645, 633-638 (2025) | `B191B0A365A64B4AB2791D117069ED17A2933D03554A662CED58B37DF52018F4` |
| `glm5-arxiv-2602.15763.pdf` | [arXiv:2602.15763](https://arxiv.org/abs/2602.15763) | Retrieved 14 July 2026 | `E20742FF36E08DC361DE6973F7F72AD38E107EDF8FD92D2A777A8428FC9B8F0E` |
| `composer2-technical-report.pdf` | [Cursor technical report](https://cursor.com/resources/Composer2.pdf) | Retrieved 14 July 2026 | `547BD9133843AE03F549B7D6F694D8236F2B124CDFEBAE9990561D6AF4102F3B` |

The GLM-5.2 and Composer 2.5 sources are first-party web research articles rather than
standalone PDFs: [GLM-5.2](https://z.ai/blog/glm-5.2) and
[Composer 2.5](https://cursor.com/blog/composer-2-5).

To retrieve the current anchored version:

```powershell
curl.exe --fail --location --output papers\deepseek-r1-arxiv-2501.12948v2.pdf https://arxiv.org/pdf/2501.12948v2
curl.exe --fail --location --output papers\glm5-arxiv-2602.15763.pdf https://arxiv.org/pdf/2602.15763
curl.exe --fail --location --output papers\composer2-technical-report.pdf https://cursor.com/resources/Composer2.pdf
```
