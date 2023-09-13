import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

def expl_var(evr) -> None:
    cumulative_variance = np.cumsum(evr)
    index_80_percent = np.where(cumulative_variance >= 0.8)[0][0]

    fig, ax1 = plt.subplots(figsize=(8, 4), facecolor="none")

    ax1.bar(range(1, len(evr)+1), evr, alpha=0.8, align='center')
    ax1.set_ylabel('Explained Variance Ratio', color='b')
    ax1.set_xlabel('Principal Component')
    ax1.set_facecolor('none')
    for label in ax1.get_yticklabels():
        label.set_color("b")

    ax2 = ax1.twinx()
    ax2.step(range(1, len(evr)+1), cumulative_variance, where='mid', label='Cumulative Explained Variance', color='g')
    ax2.axvline(x=index_80_percent + 1, color='r', linestyle='--', label='80% of Explained Variance')
    ax2.set_ylabel('Cumulative Explained Variance', color='g')
    for label in ax2.get_yticklabels():
        label.set_color("g")
    ax1.set_ylim([0, max(evr)*1.1])
    ax2.set_ylim([0, 1])
    ax2.set_facecolor('none')

    plt.tight_layout()
    plt.show()
    #print(f"80% of variance is explained by {index_80_percent + 1} components")

def biplot(score, coeff, labels, names):
    xs = score[:,0]
    ys = score[:,1]
    n = coeff.shape[0]
    scalex = 1.0 / (xs.max() - xs.min())
    scaley = 1.0 / (ys.max() - ys.min())
    
    plt.scatter(xs * scalex, ys * scaley)
    for i, (x, y) in enumerate(zip(xs * scalex, ys * scaley)):
        plt.text(x, y, names[i], color='black', fontsize=9)  # Annotate each point with its index

    for i in range(n):
        plt.arrow(0, 0, coeff[i,0], coeff[i,1], color='r', alpha=0.5)
        if labels is None:
            plt.text(coeff[i,0] * 1.15, coeff[i,1] * 1.15, "Var" + str(i + 1), color='g', ha='center', va='center')
        else:
            plt.text(coeff[i,0] * 1.15, coeff[i,1] * 1.15, labels[i], color='g', ha='center', va='center')

    plt.xlabel("PC{}".format(1))
    plt.ylabel("PC{}".format(2))
    plt.grid()