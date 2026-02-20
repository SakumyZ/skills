# React + TypeScript + MUI 组件模板

## 页面组件

```tsx
import { type FC } from 'react'
import { Box, Typography } from '@mui/material'

interface ${ComponentName}Props {
  // TODO: 定义 props
}

const ${ComponentName}: FC<${ComponentName}Props> = (props) => {
  return (
    <Box>
      <Typography variant="h5">${ComponentName}</Typography>
      {/* TODO: 实现页面内容 */}
    </Box>
  )
}

export default ${ComponentName}
```

## 业务组件

```tsx
import { type FC } from 'react'
import { Box } from '@mui/material'

interface ${ComponentName}Props {
  // TODO: 定义 props
}

export const ${ComponentName}: FC<${ComponentName}Props> = ({
  // TODO: 解构 props
}) => {
  return (
    <Box>
      {/* TODO: 实现组件内容 */}
    </Box>
  )
}
```

## 共通组件

```tsx
import { type FC, type ReactNode } from 'react'
import { Box, type SxProps, type Theme } from '@mui/material'

interface ${ComponentName}Props {
  children?: ReactNode
  sx?: SxProps<Theme>
  // TODO: 定义 props
}

export const ${ComponentName}: FC<${ComponentName}Props> = ({
  children,
  sx,
  ...rest
}) => {
  return (
    <Box sx={sx} {...rest}>
      {children}
    </Box>
  )
}
```

## 带状态管理的组件

```tsx
import { type FC, useState, useCallback } from 'react'
import { Box } from '@mui/material'

interface ${ComponentName}Props {
  // TODO: 定义 props
}

export const ${ComponentName}: FC<${ComponentName}Props> = (props) => {
  const [loading, setLoading] = useState(false)
  // TODO: 添加状态

  const handleAction = useCallback(async () => {
    setLoading(true)
    try {
      // TODO: 实现逻辑
    } finally {
      setLoading(false)
    }
  }, [])

  return (
    <Box>
      {/* TODO: 实现组件内容 */}
    </Box>
  )
}
```

## 表格组件

```tsx
import { type FC, useState } from 'react'
import {
  Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, TablePagination
} from '@mui/material'

interface ${ComponentName}Column<T> {
  key: keyof T
  label: string
  width?: number
  render?: (value: T[keyof T], row: T) => ReactNode
}

interface ${ComponentName}Props<T> {
  columns: ${ComponentName}Column<T>[]
  data: T[]
  loading?: boolean
}

export const ${ComponentName} = <T extends Record<string, unknown>>({
  columns,
  data,
  loading = false,
}: ${ComponentName}Props<T>) => {
  const [page, setPage] = useState(0)
  const [rowsPerPage, setRowsPerPage] = useState(10)

  return (
    <TableContainer component={Paper}>
      <Table>
        <TableHead>
          <TableRow>
            {columns.map((col) => (
              <TableCell key={String(col.key)} width={col.width}>
                {col.label}
              </TableCell>
            ))}
          </TableRow>
        </TableHead>
        <TableBody>
          {data
            .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
            .map((row, index) => (
              <TableRow key={index}>
                {columns.map((col) => (
                  <TableCell key={String(col.key)}>
                    {col.render ? col.render(row[col.key], row) : String(row[col.key] ?? '')}
                  </TableCell>
                ))}
              </TableRow>
            ))}
        </TableBody>
      </Table>
      <TablePagination
        component="div"
        count={data.length}
        page={page}
        rowsPerPage={rowsPerPage}
        onPageChange={(_, newPage) => setPage(newPage)}
        onRowsPerPageChange={(e) => {
          setRowsPerPage(parseInt(e.target.value, 10))
          setPage(0)
        }}
      />
    </TableContainer>
  )
}
```

## 表单组件

```tsx
import { type FC, useCallback } from 'react'
import { Box, Button, TextField } from '@mui/material'
import { useForm, Controller, type SubmitHandler } from 'react-hook-form'

interface ${ComponentName}FormData {
  // TODO: 定义表单字段
}

interface ${ComponentName}Props {
  onSubmit: (data: ${ComponentName}FormData) => void | Promise<void>
  defaultValues?: Partial<${ComponentName}FormData>
}

export const ${ComponentName}: FC<${ComponentName}Props> = ({
  onSubmit,
  defaultValues,
}) => {
  const { control, handleSubmit, formState: { errors, isSubmitting } } = useForm<${ComponentName}FormData>({
    defaultValues,
  })

  const handleFormSubmit: SubmitHandler<${ComponentName}FormData> = useCallback(
    async (data) => {
      await onSubmit(data)
    },
    [onSubmit]
  )

  return (
    <Box component="form" onSubmit={handleSubmit(handleFormSubmit)}>
      {/* TODO: 添加表单字段 */}
      <Button type="submit" variant="contained" disabled={isSubmitting}>
        提交
      </Button>
    </Box>
  )
}
```
