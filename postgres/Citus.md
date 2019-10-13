# Citus 使用与优化

## 创建 Citus 集群

```sql
-- 创建 Citus 扩展
CREATE EXTENSION citus;
```

### 节点

#### 协调节点

存储所有的元数据，不存储实际数据。为应用系统提供服务，向各工作节点发送查询请求，并汇总结果。创建 Citus 扩展后，执行增加工作节点命令即为协调节点：

```sql
-- 在协调节点上增加工作节点：
SELECT * from master_add_node('citus-worker-01', 5432);
SELECT * from master_add_node('citus-worker-02', 5432);
SELECT * from master_add_node('citus-worker-03', 5432);
-- 删除工作节点
UPDATE pg_dist_shard_placement set shardstate = 3 where nodename = 'citus-worker-03' and nodeport = 5432;
SELECT master_remove_node('citus-worker-03', 5432);
-- 查看工作节点：
SELECT * FROM master_get_active_worker_nodes();
-- 查看分片分布
SELECT a.logicalrelid, a.shardid, a.shardstorage, a.shardminvalue, a.shardmaxvalue, \
    b.shardstate, b.shardlength, b. nodename , b.nodeport, b.placementid from \
    pg_dist_shard a, pg_dist_shard_placement b \
    where a.shardid = b.shardid order by b.shardid, b.placementid;
```

#### 工作节点

不存储元数据，存储实际数据。执行协调节点发来的查询请求。

### 数据分片与副本

将同一张逻辑表中的数据按照一定策略，分别存储到不同的物理表中去，物理表被称为分片。

分片原则

在设计分布式数据库的时候，设计者必须考虑数据如何分布在各个场地上，也就是全局数据应该如何进行逻辑划分和物理划分。哪些数据应该分布式存放，哪些不需要分布式存放，哪些数据需要复制。对系统惊醒全盘考虑，使系统性能最优。但是无论如何进行分片都应该遵循以下原则：

> 完备性：所有全局数据都要映射到某个片段上。

> 可重构性：所有片段必须可以重新构成全局数据。

> 不相交性：划分的个片段所包含的数据无交集。

副本，即分片的冗余。

#### 设置分片和副本数量

```sql
-- 设置表分片数
SET citus.shard_count TO 64;
-- 设置表分片的副本数量
SET citus.shard_replication_factor TO 2;
```

### 创建分布表

create_distributed_table() 函数用于定义分布式表，如果它是散列分布式表，则创建其分片。此函数接受表名，分发列和可选的分发方法，并插入适当的元数据以将表标记为分布式。如果未指定分发方法，则该函数默认为“哈希”分布。如果表是散列分布式的，则该函数还会根据分片计数和分片复制因子配置值创建工作分片。如果表包含任何行，则它们会自动分发到工作节点。

该函数还使用 citus.shard_count 和 citus.shard_replication_factor 配置值在工作节点上创建分片和副本。

此函数替换 master_create_distributed_table() 后跟 master_create_worker_shards() 的用法。

参数
table_name：            需要分发的表的名称。

distribution_column：   要分发表的列。

distribution_type：     (可选）要分发表的方法。允许的值是append或hash，默认为'hash'。

colocate_with：         (可选）包括另一个表的共址组中的当前表。默认情况下，表由相同类型的列分布，具有相同的分片计数并具有相同的复制因子时共同定位。可能的值colocate_with是default，none要启动新的协同定位组，还是要与该表共同定位的另一个表的名称。（参见共同定位表。）

请记住默认值是colocate_with隐式共址。正如Table Co-Location所解释的那样，当表相关或将被连接时，这可能是一件好事。但是，当两个表不相关但碰巧对其分发列使用相同的数据类型时，意外地共同定位它们会降低分片重新平衡期间的性能。表格碎片将在“级联”中不必要地移动到一起。

如果新的分布式表与其他表无关，则最好指定。colocate_with => 'none'

返回值
N / A

示例

```sql

-- 此函数通知 Citus 应该在 repo_id 列上分发 github_events 表（通过散列列值）。
SELECT create_distributed_table('github_events', 'repo_id', 'hash');

-- 此函数通知 Citus 应该在 repo_id 列上分发 github_events 表（通过散列列值）。并与 github_repo 表 repo_id 的复制因子时共同定位
SELECT create_distributed_table('github_events'， 'repo_id'，colocate_with => 'github_repo');

```

### 创建引用表
 
create_reference_table() 函数用于定义小型引用或维度表。此函数接受表名，并创建仅包含一个分片的分布式表，并复制到每个工作节点。

参数
table_name：需要分发的小维或引用表的名称。

返回值
N / A

示例
此示例通知数据库应将country表定义为引用表

```sql
SELECT create_reference_table('country');
```

### 升级为引用表

upgrade_to_reference_table() 函数采用分片计数为1的现有分布式表，并将其升级为可识别的引用表。调用此函数后，该表将如同使用create_reference_table 创建一样。

参数
table_name：分布式表的名称（具有分片计数= 1），它将作为引用表分发。

返回值
N / A

示例
此示例通知数据库应将 country 表定义为引用表

```sql
SELECT upgrade_to_reference_table('country');
```

参考：
    <http://docs.citusdata.com/en/v8.3/develop/api_udf.html#create-distributed-table>
