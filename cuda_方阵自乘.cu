#include<cuda_runtime.h>
#include<stdio.h>
#include<time.h>
#include<stdlib.h>
__global__ void Comp(int**ctable,int**result,int i_N)
{
	int i=threadIdx.x;
	int j=threadIdx.y;
	for(int z=0;z<i_N;z++)
		result[i][j]+=ctable[z][j]*ctable[i][z];
}
int** MallocDeviceDoubleArray(int** head,int Array_i,int Array_j);
int** MallocHostDoubleArray(int Array_i,int Array_j);
int main()
{
	int i_N,j_N;
	printf("���������Ĵ�С i,j\n");
	scanf("%d %d",&j_N,&i_N);
	int** table=MallocHostDoubleArray(i_N,j_N);
	printf("���������Ԫ��\n");
	for(int i=0;i<i_N;i++)
		for(int j=0;j<j_N;j++)
			scanf("%d",&table[i][j]);
	int** result=MallocHostDoubleArray( i_N,j_N);
	int* cresult_head,*ctable_head;
	int** cresult =MallocDeviceDoubleArray(&cresult_head,i_N,j_N),**ctable=MallocDeviceDoubleArray(&ctable_head,i_N,j_N);
	cudaMemset(cresult_head,0,sizeof(cresult_head));
	cudaMemcpy(ctable_head,*table,sizeof(int)*i_N*j_N,cudaMemcpyHostToDevice);
	dim3 threadsize;
	threadsize.x=i_N;
	threadsize.y=j_N;
	Comp<<<1,threadsize>>>(ctable,cresult,i_N);
	cudaMemcpy(*result,cresult_head,sizeof(int)*i_N*j_N,cudaMemcpyDeviceToHost);
	for(int i=0;i<i_N;i++)
	{
		for(int j=0;j<j_N;j++)
			printf("%6d ",result[i][j]);
		printf("\n");
	}
	return 0;
}
/*
*@�ö�ά�������ʽ����һά����
*@����ά������ʣ�һά����洢��
*@Device�����ɶ�̬��ά���飬head����һά����ĵ�ַ���Ա�memcpyʹ�ã�
*@����ֵΪ��ά����ָ��
*/
int** MallocDeviceDoubleArray(int** head,int Array_i,int Array_j)
{
	int** cresult,*temp,**temp3;
	cudaMalloc((void**)&cresult,sizeof(int*)*Array_i);
	cudaMalloc((void**)&temp,sizeof(int)*Array_i*Array_j);
	temp3=(int**)malloc(sizeof(int*)*Array_i);
	for(int i=0;i<Array_i;i++)
		temp3[i]=i*Array_j+temp;
	*head=temp;
	cudaMemcpy(cresult,temp3,sizeof(int*)*Array_i,cudaMemcpyHostToDevice);
	return cresult;
}
int **MallocHostDoubleArray(int Array_i,int Array_j)
{
	int **table,*table2;
	table2=(int*)malloc(sizeof(int)*Array_i*Array_j);
	table=(int**)malloc(sizeof(int*)*Array_i);
	for(int i=0;i<Array_i;i++)
	{
		table[i]=Array_j*i+table2;
	}
	return table;
}