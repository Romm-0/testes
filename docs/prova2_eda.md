# Questão 1 (viúva negra)

Analise as informações referentes a estrutura de dado básica:

- [ ] Uma lista linear X é uma sequência de zeros ou mais itens x1, x2, ..., xn, em que xi é de um determinado tipo e n representa o tamanho de X.

- [ ] Uma pilha é uma lista linear em que as inserções, consultas e retiradas são feitos em apenas um extremo da lista.

- [ ] Uma fila é uma lista linear em que todas as inserções são realizadas em um extremo da lista e todos os acessos e retiradas são realizados no mesmo extremos da lista.

---

# Questão 2 (viúva negra)

As listas encadeadas simples são normalmente utilizadas para relacionar itens que precisam ser exibidos ou manipulados por meio de estruturas dinâmicas. Em relação a manipulação de uma lista encadeada simplesmente, analise os itens:

- [ ] A inclusão de um elemento em uma lista encadeada simples pode ser realizada somente no início e no final da lista.

- [ ] Um elemento de uma lista encadeada simples só pode ser excluído no início e no final da lista.

- [ ] Uma lista encadeada simples (sem descritor) está vazia se ela aponta para nulo.

- [ ] A complexidade de inserção na calda de uma lista encadeada simples sem descritor é O(n).

- [ ] A complexidade de exclusão na cabeça de uma lista encadeada simples sem descritor é O(1).

---

# Questão 3 (viúva negra)

Assinale apenas as sentenças verdadeiras abaixo sobre árvore binária de busca (ABB):

- [ ] Uma ABB é uma estrutura de dados na qual cada nó tem no máximo dois filhos.

- [ ] Em uma ABB contendo chaves únicas, o filho esquerdo de um nó sempre contém uma chave menor que a chave do nó pai.

- [ ] A altura de uma ABB é sempre igual ao número de nós da árvore.

- [ ] A remoção de um nó em uma ABB balanceada pode exigir a reorganização da estrutura da árvore.

---

# Questão 4 (viúva negra)

Assinale apenas as sentenças verdadeiras abaixo:

- [ ] A operação de inserção em uma pilha tem complexidade O(1).

- [ ] A operação de remoção em uma fila tem complexidade O(1).

- [ ] A operação de busca em uma ABB balanceada tem complexidade O(log n), onde n é o número de nós da árvore.

- [ ] A operação de inserção em uma ABB balanceada tem complexidade O(log n), onde n é o número de nós da árvore.

- [ ] A operação de remoção em uma ABB tem complexidade O(log n), onde n é o número de nós da árvore.

---

# Questão 1 (capitão américa)

sabe-se que t1(n) = n²+60n-30 reflete o tempo em ns que uma função f1 leva para fazer um cálculo em um vetor de tamanho n e que t2(n) = 700n+5600 reflete o tempo em ns que a função f2 leva para fazer o mesmo cálculo. Marque a opção correta (apenas uma):

- [ ] Somente para vetores com 180 ou mais elementos f1 retornam o resultado mais rápido.

- [ ] f2 = O(n²).

- [ ] Somente para vetores com 18 ou mais elementos f1 retorna o resultado mais rápido.

- [ ] f1 = Ω(f2).

- [ ] f2 sempre será mais rápida.

- [ ] Nenhuma está correta.

---

# Questão 2 (capitão américa modificada)

Quais os métodos de ordenação implementados nas seguintes funcções?

usem o swap para todos
```c
void swap (int *a, int *b) {
	int temp = *a;
	*a = *b;
	*b = temp;
}
```

```c
void sort(int arr[], int n) {
for (int i = 0; i < n - 1; i++) {
	for (int j = 0; j < n - i - 1; j++) {
		if (arr[j] > arr[j + 1]) {
			swap (arr[j], arr[j+1])
			}
		}
	}
}
```
- [ ] Quick sort
- [ ] Bubble sort
- [ ] Merge sort
- [ ] Selection sort

---

```c
void sort(int arr[], int n) {
	for (int i = 0; i < n - 1; i++) {
		int min_idx = i;
		for (int j = i + 1; j < n; j++) {
			if (arr[j] < arr[min_idx]) {
				min_idx = j;
			}
		}
		swap (arr[min_idx], arr[i])
	}
}
```
- [ ] Quick sort
- [ ] Bubble sort
- [ ] Merge sort
- [ ] Selection sort

---

```c
int partition(int arr[], int menor, int maior) {
	int pivot = arr[menor];
	int i = (menor - 1);

	for (int j = menor; j <= maior - 1; j++) {
		if (arr[j] <= pivot) {
			i++;
			swap(&arr[i], &arr[j]);
		}
	}
	swap(&arr[i + 1], &arr[maior]);
	return (i + 1);
}

void sort3(int arr[], int menor, int maior) {
	if (menor < maior) {
		int pi = partition(arr, menor, maior);
			sort3(arr, menor, pi - 1);
			sort3(arr, pi + 1, maior);
	}
}
```
- [ ] Quick sort
- [ ] Bubble sort
- [ ] Merge sort
- [ ] Selection sort

---

# Questão 3 (capitão américa)

Assinale apenas as sentenças verdadeiras abaixo:

- [ ] No melhor caso, o método QuickSort é O(n log(n)).

- [ ] O método de ordenação por seleção (SelectionSort) é quadrático.

- [ ] O método BubbleSort é logarítmico.

- [ ] No melhor e no pior caso, o método de ordenação MergeSort é linearítmico.
