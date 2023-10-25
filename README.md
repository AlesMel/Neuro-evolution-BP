# 🚗 Autonomous Car

Welcome to the repository of my Bachelor Thesis, where I have designed and implemented an autonomous car control system using neuro evolution techniques in MATLAB. 
The core of the system uses neural networks evolved through genetic algorithms to drive the car based on various sensor inputs.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation & Usage](#installation--usage)
- [Dataset & Training](#dataset--training)
- [Contributing & Feedback](#contributing--feedback)
- [License](#license)

## Features

- **Input Sensors**:
  - Camera
  - Radar
  - Fusion of Camera and Radar

- **Outputs**:
  - Rotation of Front Wheels
  - Speed Control

## Requirements
- MATLAB R20XX or newer
- Parallel toolbox
- Color formated output toolbox see "Pouzivatelska prirucka"
- Navigation toolbox (used for occupancies)
## Installation & Usage

1. **Clone the Repository**:

```bash
git clone https://github.com/AlesMel/Neuro-evolution-BP.git
cd Neuro-evolution-BP
```
- See "PouzivatelskaPrirucka.pdf"
Run the Main Script:

matlab
Copy code
main
Ensure that you have the required toolboxes installed. If you encounter any issues, refer to the docs folder for in-depth documentation or raise an issue.


## Dataset & Training:

```markdown
## Dataset & Training

The system uses a custom dataset created from simulated runs. For details on how the dataset was collected, preprocessing steps, and the training regimen, please refer to `DATA.md` and `TRAINING.md` in the `docs` folder.
```
## Contributing & Feedback
While this project was primarily developed for academic purposes, contributions, feedback, and suggestions are always welcome. Create a pull request or raise an issue if you wish to contribute.

## License

This project is licensed under the MIT License. For more details, see the [LICENSE](./LICENSE) file.

---

Thank you for checking out my Bachelor Thesis project! If you have any questions or want to get in touch, feel free to reach out.

---
