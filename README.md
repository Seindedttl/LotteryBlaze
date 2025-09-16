LotteryBlaze
-------------

* * * * *

🚀 Overview
-----------

The `LotteryBlaze` smart contract is a decentralized, secure, and transparent lottery and raffle system built on the Stacks blockchain. It enables the creation and management of multiple concurrent lotteries with configurable parameters, including entry fees, duration, and participant limits. The contract leverages **verifiable randomness** for a fair and unbiased winner selection process. It includes robust prize distribution, automated fee collection, and comprehensive management functions, such as an emergency pause feature, to ensure the system's integrity and security.

The contract is designed to be fully on-chain, providing a trustless environment where all transactions and lottery outcomes are publicly verifiable. Participants can enter lotteries, and winners are automatically and securely paid out, making it an ideal platform for transparent, decentralized raffles and games of chance.

✨ Features
----------

-   **Multi-Lottery Support**: Create and manage multiple concurrent lotteries, each with unique settings.

-   **Configurable Lotteries**: Set custom entry fees, duration (in blocks), and maximum participants for each lottery instance.

-   **Verifiable Randomness**: The winner selection process uses block-based data to generate a pseudo-random number, which is transparent and verifiable by anyone on the blockchain.

-   **Automated Prize Distribution**: The contract automatically distributes the prize pool to the winner, minus a small, configurable house fee.

-   **House Fee Collection**: A percentage of each lottery's prize pool is automatically collected and stored within the contract, providing a sustainable revenue model.

-   **Emergency Pause Control**: The contract owner can instantly pause critical functions, such as creating or entering lotteries, in the event of an emergency or security threat.

-   **Comprehensive Analytics (Owner-Only)**: The contract owner can generate a detailed analytics report on lottery performance, participant behavior, and revenue projections to inform strategic decisions.

-   **Participant Tracking**: Tracks and stores participant information, including entry block and ticket number, ensuring no duplicate entries and providing a clear record.

-   **Withdrawal Management**: The contract owner can withdraw the accumulated house fees from the contract at any time.

* * * * *

🛠️ How It Works
----------------

### Core Concepts

-   **Lottery**: An instance of a raffle defined by its `id`, `name`, `entry-fee`, `end-block`, and `max-participants`.

-   **Participants**: Users who have paid the entry fee and entered a specific lottery.

-   **Prize Pool**: The total amount of STX collected from all participants' entry fees for a given lottery.

-   **House Fee**: A small percentage of the prize pool collected by the contract owner to cover operational costs and provide revenue.

-   **Winner Selection**: The winner is chosen using a pseudo-random algorithm based on the block height and other on-chain data, making it unpredictable and transparent.

### Contract Maps & Variables

-   `next-lottery-id` (var): Stores the ID for the next lottery to be created.

-   `total-collected-fees` (var): Tracks the total amount of STX collected as house fees.

-   `emergency-pause` (var): A boolean flag that, when true, pauses key contract functionalities.

-   `lotteries` (map): Stores the detailed data for each lottery, indexed by its ID.

-   `participants` (map): A mapping to track if a specific user has entered a specific lottery.

-   `lottery-participants` (map): Maps a lottery ticket number to the principal of the participant who holds it.

-   `user-lottery-count` (map): Tracks the number of lotteries each user has entered.

* * * * *

📞 Public Functions
-------------------

| Function Name | Description | Parameters |
| --- | --- | --- |
| **`create-lottery`** | Creates a new lottery with specified parameters. | `name` (string), `entry-fee` (uint), `duration-blocks` (uint), `max-participants` (uint) |
| **`enter-lottery`** | Allows a user to enter a lottery by paying the entry fee. | `lottery-id` (uint) |
| **`draw-winner`** | The contract owner calls this to select a winner and distribute the prize. | `lottery-id` (uint) |
| **`emergency-pause-toggle`** | Allows the contract owner to toggle the emergency pause. | None |
| **`withdraw-house-fees`** | The contract owner can withdraw all accumulated house fees. | None |
| **`generate-comprehensive-lottery-analytics-and-insights`** | An owner-only function to generate a detailed analytics report. | `analysis-period-blocks` (uint), `include-participant-behavior` (bool), `generate-revenue-projections` (bool), `create-optimization-recommendations` (bool) |

Export to Sheets

* * * * *

🔒 Private Functions
--------------------

The `LotteryBlaze` contract also relies on several **private functions** to handle core logic and calculations internally. These functions are crucial for the contract's operation but cannot be called directly by external users.

| Function Name | Description | Parameters |
| --- | --- | --- |
| **`calculate-house-fee`** | This function calculates the amount of the **house fee** to be collected from the prize pool. It takes the total prize pool amount as an input and returns the fee based on the `HOUSE-FEE-PERCENTAGE` constant. | `amount` (uint) |
| **`generate-random-winner`** | This function is responsible for the fair and transparent **winner selection**. It uses a pseudo-random number generation algorithm based on various on-chain variables, including the block height, block time, and lottery ID. The function's output is a winning ticket number, which is then used to identify the winner from the list of participants. | `lottery-id` (uint), `participant-count` (uint) |
| **`is-lottery-active`** | This utility function checks whether a specific lottery is currently **active**. It verifies that the current block height is within the lottery's start and end blocks and that its status is set to "ACTIVE". This prevents users from entering lotteries that have already ended or been drawn. | `lottery-id` (uint) |
| **`update-user-stats`** | This function updates the `user-lottery-count` map, incrementing the number of lotteries a particular user has entered. This data can be used to generate analytics and insights for the contract owner. | `user` (principal) |

Export to Sheets

* * * * *

🛡️ Security
------------

The `LotteryBlaze` contract has been designed with several security considerations in mind:

-   **Access Control**: Critical management functions, such as `draw-winner`, `emergency-pause-toggle`, and `withdraw-house-fees`, are restricted to the `CONTRACT-OWNER` to prevent unauthorized access.

-   **Reentrancy Protection**: All state updates are performed before external calls (`stx-transfer?`), mitigating the risk of reentrancy attacks.

-   **Emergency Pause**: The `emergency-pause` feature provides an immediate security failsafe, allowing the owner to halt contract operations if a vulnerability is discovered.

-   **Input Validation**: The `create-lottery` function validates all input parameters to prevent the creation of invalid lotteries.

-   **Error Handling**: The contract uses a comprehensive set of error codes to provide clear feedback on why a transaction failed.

* * * * *

🤝 Contribution
---------------

We welcome and appreciate all contributions to the `LotteryBlaze` project. Whether you are reporting a bug, suggesting a new feature, or submitting code, your help makes the platform more robust and secure.

### **How to Contribute**

1.  **Fork the repository**: Start by forking the `LotteryBlaze` repository on GitHub. This creates a personal copy of the project where you can make changes.

2.  **Clone the forked repository**: Clone your forked repository to your local machine using the following command, replacing `[your-username]` with your GitHub username:

    Bash

    ```
    git clone https://github.com/[your-username]/LotteryBlaze.git

    ```

3.  **Create a new branch**: Before making any changes, create a new branch for your work. This keeps your changes organized and separate from the main branch. Use a descriptive name for your branch, such as `fix-bug-in-draw-function` or `feature-add-new-analytics`.

    Bash

    ```
    git checkout -b your-branch-name

    ```

4.  **Make your changes**: Implement your bug fix, new feature, or documentation update. Ensure your code is clean, well-commented, and adheres to the project's coding standards.

5.  **Test your changes**: Thoroughly test your code to ensure it works as expected and does not introduce any new issues. Run any existing tests and create new ones for your specific changes if necessary.

6.  **Commit your changes**: Once you are confident in your changes, commit them to your local branch with a clear and concise commit message. A good commit message explains what you did and why.

    Bash

    ```
    git commit -m "feat: Add new analytics feature"

    ```

7.  **Push to your fork**: Push your changes from your local machine to your forked repository on GitHub.

    Bash

    ```
    git push origin your-branch-name

    ```

8.  **Create a pull request**: Navigate to your forked repository on GitHub and click the "New Pull Request" button. Provide a detailed description of your changes, including the problem you are solving, the solution you implemented, and any relevant context. A maintainer will then review your pull request, provide feedback, and merge it if it meets the project's standards.

* * * * *

📜 License
----------

This smart contract is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2025 LotteryBlaze

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
