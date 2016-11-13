#include<cuda_runtime.h>
#include<stdio.h>
#include<time.h>
#include<stdlib.h>
__global__ void Comp(int**ctable1,int **ctable2,int **cresult,int j_N)
{
	int i=threadIdx.x;
	int j=threadIdx.y;
	for(int z=0;z<j_N;z++)
		cresult[i][j]+=ctable1[i][z]*ctable2[z][j];
}
int** MallocDeviceDoubleArray(int** head,int Array_i,int Array_j);
int** MallocHostDoubleArray(int Array_i,int Array_j);
int main()
{
	int i1_max,j1_max,i2_max,j2_max;
	printf("����һ��������˵ĳ���\n");
	printf("���������A��С(���д�С)\n");
	scanf("%d %d",&j1_max,&i1_max);	//���þ���Ĵ�С
	int **table1=MallocHostDoubleArray(i1_max,j1_max);
	printf("���������A������\n");
	for(int i=0;i<i1_max;i++)
		for(int j=0;j<j1_max;j++)
			scanf("%d",&table1[i][j]);

	printf("���������B��С(���д�С)\n");
	scanf("%d %d",&j2_max,&i2_max);	//���þ���Ĵ�С
	int **table2=MallocHostDoubleArray(i2_max,j2_max);	//Ϊ�����������host�ռ�
	printf("���������B������\n");
	for(int i=0;i<i2_max;i++)
		for(int j=0;j<j2_max;j++)
			scanf("%d",&table2[i][j]);

	/*
	for(int i=0;i<i1_max;i++)
	{
	for(int j=0;j<j1_max;j++)
	printf("%d ",table1[i][j]);
	printf("\n");
	}

	for(int i=0;i<i2_max;i++)
	{
	for(int j=0;j<j2_max;j++)
	printf("%d ",table2[i][j]);
	printf("\n");
	}*/


	int **result=MallocHostDoubleArray(i1_max,j2_max);		//���䴢������host�ռ�
	int *ctable1_head,*ctable2_head,*cresult_head;
	int **ctable1=MallocDeviceDoubleArray(&ctable1_head,i1_max,j1_max),**ctable2=MallocDeviceDoubleArray(&ctable2_head,i2_max,j2_max),**cresult=MallocDeviceDoubleArray(&cresult_head,i1_max,j2_max);	//Ϊ������������Դ�ռ�
	cudaMemset(cresult_head,0,sizeof(cresult_head));
	cudaMemcpy(ctable1_head,*table1,sizeof(int)*i1_max*j1_max,cudaMemcpyHostToDevice);
	cudaMemcpy(ctable2_head,*table2,sizeof(int)*i2_max*j2_max,cudaMemcpyHostToDevice);		//Ϊtable1��2��ֵ���Դ�
	dim3 threadmax;
	threadmax.x=i1_max;
	threadmax.y=j2_max;
	Comp<<<1,threadmax>>>(ctable1,ctable2,cresult,j1_max);
	cudaMemcpy(*result,cresult_head,sizeof(int)*i1_max*j2_max,cudaMemcpyDeviceToHost);
	for(int i=0;i<i1_max;i++)
	{
		for(int j=0;j<j2_max;j++)
			printf("%d ",result[i][j]);
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