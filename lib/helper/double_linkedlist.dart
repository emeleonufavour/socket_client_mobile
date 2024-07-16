import 'dart:developer';

import 'package:flutter/material.dart';

import '../models/node.dart';

class DoubleLinkedList<T> extends ChangeNotifier {
  Node<T>? head;
  Node<T>? tail;

  void append(T value, [T? newPreviousNodeValue]) {
    Node<T> newNode = Node(value);
    if (tail == null) {
      head = tail = newNode;
    } else {
      tail!.next = newNode;
      newNode.prev = tail;
      tail = newNode;
      // Update the previous node when a new item is added
      updateLeft(newNode,
          newValue: newPreviousNodeValue ?? newNode.prev!.value);
    }
    notifyListeners();
  }

  Node<T>? find(T value) {
    Node<T>? current = head;
    while (current != null) {
      if (current.value == value) {
        return current;
      }
      current = current.next;
    }
    return null;
  }

  T? getLeft(Node<T> node) {
    return node.prev?.value;
  }

  void updateLeft(Node<T> node, {required T newValue}) {
    if (node.prev != null) {
      node.prev!.value = newValue;
      // notifyListeners();
    }
  }

  void printList() {
    Node<T>? current = head;
    while (current != null) {
      log(current.value.toString());
      current = current.next;
    }
  }
}
