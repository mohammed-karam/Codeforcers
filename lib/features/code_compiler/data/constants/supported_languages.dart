import 'package:codeforcers/features/code_compiler/data/models/language_model.dart';

const List<LanguageModel> kSupportedLanguages = [
  LanguageModel(
    displayName: 'C++',
    compilerId: 'g++-15',
    fileExtension: 'cpp',
    boilerplate: '''#include <bits/stdc++.h>
using namespace std;

int main() {
    // Write your code here
    cout << "Hello, World!" << endl;
    return 0;
}''',
  ),
  LanguageModel(
    displayName: 'C',
    compilerId: 'gcc-15',
    fileExtension: 'c',
    boilerplate: '''#include <stdio.h>

int main() {
    // Write your code here
    printf("Hello, World!\\n");
    return 0;
}''',
  ),
  LanguageModel(
    displayName: 'Python 3',
    compilerId: 'python-3.14',
    fileExtension: 'py',
    boilerplate: '''# Write your code here
print("Hello, World!")''',
  ),
  LanguageModel(
    displayName: 'Java',
    compilerId: 'openjdk-25',
    fileExtension: 'java',
    boilerplate: '''public class Main {
    public static void main(String[] args) {
        // Write your code here
        System.out.println("Hello, World!");
    }
}''',
  ),
  LanguageModel(
    displayName: 'Rust',
    compilerId: 'rust-1.93',
    fileExtension: 'rs',
    boilerplate: '''fn main() {
    // Write your code here
    println!("Hello, World!");
}''',
  ),
  LanguageModel(
    displayName: 'Go',
    compilerId: 'go-1.26',
    fileExtension: 'go',
    boilerplate: '''package main

import "fmt"

func main() {
    // Write your code here
    fmt.Println("Hello, World!")
}''',
  ),
  LanguageModel(
    displayName: 'C#',
    compilerId: 'dotnet-csharp-9',
    fileExtension: 'cs',
    boilerplate: '''using System;

class Program {
    static void Main() {
        // Write your code here
        Console.WriteLine("Hello, World!");
    }
}''',
  ),
];
