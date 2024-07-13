class Node<T> {
  T value;
  Node<T>? next;
  Node<T>? prev;

  Node(this.value);

  @override
  String toString() {
    return "Node($value)";
  }
}
