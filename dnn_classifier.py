import pandas as pd
import tensorflow as tf
import numpy as np


def train_input_fn(features, labels, batch_size=50):
    """
    Input function for training.

    Args:

    features: `DataFrame`

    labels: `DataFrame`

    batch_size: `int`

    Returns:

    dataset: `BatchDataset`
    """
    dataset = tf.data.Dataset.from_tensor_slices((dict(features), labels))
    # shuffle: larger than the number of examples ensures that the data will be well shuffled.
    # repeat: train method has an infinite supply of (shuffled) dataset set examples.
    dataset = dataset.shuffle(len(labels)).repeat().batch(batch_size)
    return dataset


def eval_input_fn(features, labels=None, batch_size=50):
    """
    Input function for evaluation or prediction (if labels is None).

    Args:

    features: `DataFrame`

    labels: `DataFrame`

    batch_size: `int`

    Returns:

    dataset: `BatchDataset`
    """
    dataset = tf.data.Dataset.from_tensor_slices(
        (dict(features), labels) if labels is not None else dict(features))
    dataset = dataset.batch(batch_size)
    return dataset


def load_data(instance_file_path, label_file_path, train_split_perc):
    """
    Load data from file, and return splitted training and testing sets.

    Args:

    instance_file_path: `str`

    label_file_path: `str`

    train_split_perc: `float`, split the data according to the percentage of training set

    Returns:

    train_instances: `DataFrame`

    train_labels: `DataFrame`

    test_instances: `DataFrame`

    test_labels: `DataFrame`
    """
    # Load data from csv file.
    instances = pd.read_csv(filepath_or_buffer=instance_file_path, header=None)
    labels = pd.read_csv(filepath_or_buffer=label_file_path, header=None)
    # Convert column names to str. (Or it will get errors when training them.)
    instances.columns = [str(column) for column in instances.columns]
    labels.columns = [str(column) for column in labels.columns]
    # Randomly split data into training set and testing set. (80% train - 20% test)
    mask = np.random.rand(len(instances)) < train_split_perc
    train_instances = instances[mask]
    train_labels = labels[mask]
    test_instances = instances[~mask]
    test_labels = labels[~mask]
    return (train_instances, train_labels, test_instances, test_labels)


def build_classifier(train_instances, train_labels):
    """
    Build a classifier with DNN (Deep Neural Network).

    Args:

    train_instances: `DataFrame`

    train_labels: `DataFrame`

    Returns:

    classifier: `DNNEstimator`
    """
    # Create feature columns to describe the data.
    feature_columns = []
    for key in train_instances.keys():
        feature_columns.append(tf.feature_column.numeric_column(key=key))
    # Build
    classifier = tf.contrib.estimator.DNNEstimator(head=tf.contrib.estimator.multi_label_head(
        n_classes=len(train_labels.columns)), feature_columns=feature_columns, hidden_units=[5, 5])
    return classifier


def main():
    instance_file_path = 'Scenes_instance_6085_703.csv'
    label_file_path = 'Scenes_label.csv'
    train_split_perc = 0.8
    batch_size = 50
    step = 500

    (train_instances, train_labels, test_instances, test_labels) = load_data(
        instance_file_path, label_file_path, train_split_perc)

    classifier = build_classifier(train_instances, train_labels)
    classifier.train(input_fn=lambda: train_input_fn(
        train_instances, train_labels, batch_size), steps=step)

    # Evaluate the model's effectiveness.
    eval_result = classifier.evaluate(input_fn=lambda: eval_input_fn(
        test_instances, test_labels, batch_size))
    print('AUC: {auc:0.3f}, AUC Precision Recall: {auc_precision_recall:0.3f}, Average Loss: {average_loss:0.3f}, Loss: {loss:0.3f}'.format(**eval_result))

    # Predict
    predictions = classifier.predict(
        input_fn=lambda: eval_input_fn(test_instances, None, batch_size))
    print('Prediction: ')
    for prediction in predictions:
        probabilities = prediction['probabilities']
        for probability in probabilities:
            print(('{:0.1f}% ').format(probability * 100)),
        print('')


if __name__ == '__main__':
    main()
