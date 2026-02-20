# Vue 3 + TypeScript + Ant Design Vue 组件模板

## 页面组件

```vue
<template>
  <div class="${component-name}">
    <a-typography-title :level="4">${ComponentName}</a-typography-title>
    <!-- TODO: 实现页面内容 -->
  </div>
</template>

<script setup lang="ts">
// TODO: 定义组件逻辑
</script>

<style scoped>
.${component-name} {
  /* TODO: 页面样式 */
}
</style>
```

## 业务组件

```vue
<template>
  <div class="${component-name}">
    <!-- TODO: 实现组件内容 -->
  </div>
</template>

<script setup lang="ts">
interface Props {
  // TODO: 定义 props
}

const props = defineProps<Props>()

const emit = defineEmits<{
  // TODO: 定义事件
}>()
</script>
```

## 共通组件

```vue
<template>
  <div class="${component-name}" v-bind="$attrs">
    <slot />
  </div>
</template>

<script setup lang="ts">
interface Props {
  // TODO: 定义 props
}

const props = withDefaults(defineProps<Props>(), {
  // TODO: 默认值
})
</script>
```

## 带状态管理的组件

```vue
<template>
  <div class="${component-name}">
    <a-spin :spinning="loading">
      <!-- TODO: 实现组件内容 -->
    </a-spin>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

interface Props {
  // TODO: 定义 props
}

const props = defineProps<Props>()

const loading = ref(false)

const fetchData = async () => {
  loading.value = true
  try {
    // TODO: 实现数据获取
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchData()
})
</script>
```

## 表格组件

```vue
<template>
  <a-table
    :columns="columns"
    :data-source="dataSource"
    :loading="loading"
    :pagination="pagination"
    row-key="id"
    @change="handleTableChange"
  >
    <!-- TODO: 自定义列插槽 -->
    <template #bodyCell="{ column, record }">
      <template v-if="column.key === 'action'">
        <a-space>
          <a-button type="link" size="small">编集</a-button>
          <a-button type="link" size="small" danger>削除</a-button>
        </a-space>
      </template>
    </template>
  </a-table>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import type { TableColumnsType, TablePaginationConfig } from 'ant-design-vue'

interface ${ComponentName}Record {
  id: string | number
  // TODO: 定义数据结构
}

interface Props {
  dataSource: ${ComponentName}Record[]
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
})

const columns: TableColumnsType = [
  // TODO: 定义列
  { title: '操作', key: 'action', width: 150 },
]

const pagination = reactive<TablePaginationConfig>({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showTotal: (total: number) => `全 ${total} 件`,
})

const handleTableChange = (pag: TablePaginationConfig) => {
  pagination.current = pag.current ?? 1
  pagination.pageSize = pag.pageSize ?? 10
}
</script>
```

## 表单组件

```vue
<template>
  <a-form
    ref="formRef"
    :model="formState"
    :rules="rules"
    layout="vertical"
    @finish="handleFinish"
  >
    <!-- TODO: 添加表单字段 -->
    <a-form-item>
      <a-space>
        <a-button type="primary" html-type="submit" :loading="submitting">
          保存
        </a-button>
        <a-button @click="handleReset">リセット</a-button>
      </a-space>
    </a-form-item>
  </a-form>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import type { FormInstance, Rule } from 'ant-design-vue'

interface ${ComponentName}FormData {
  // TODO: 定义表单数据结构
}

interface Props {
  initialValues?: Partial<${ComponentName}FormData>
}

const props = defineProps<Props>()

const emit = defineEmits<{
  submit: [data: ${ComponentName}FormData]
}>()

const formRef = ref<FormInstance>()
const submitting = ref(false)

const formState = reactive<${ComponentName}FormData>({
  // TODO: 初始值
  ...props.initialValues,
})

const rules: Record<string, Rule[]> = {
  // TODO: 校验规则
}

const handleFinish = async (values: ${ComponentName}FormData) => {
  submitting.value = true
  try {
    emit('submit', values)
  } finally {
    submitting.value = false
  }
}

const handleReset = () => {
  formRef.value?.resetFields()
}
</script>
```

## 弹窗组件

```vue
<template>
  <a-modal
    v-model:open="visible"
    :title="title"
    :confirm-loading="loading"
    @ok="handleOk"
    @cancel="handleCancel"
  >
    <slot />
  </a-modal>
</template>

<script setup lang="ts">
import { ref } from 'vue'

interface Props {
  title?: string
}

const props = withDefaults(defineProps<Props>(), {
  title: '',
})

const emit = defineEmits<{
  ok: []
  cancel: []
}>()

const visible = defineModel<boolean>('open', { default: false })
const loading = ref(false)

const handleOk = async () => {
  loading.value = true
  try {
    emit('ok')
  } finally {
    loading.value = false
  }
}

const handleCancel = () => {
  emit('cancel')
}
</script>
```
